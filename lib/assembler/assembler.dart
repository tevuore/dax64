import 'dart:collection';
import 'dart:typed_data';

import 'package:dax64/assembler/addressing_modes.dart';
import 'package:dax64/assembler/assembler_config.dart';
import 'package:dax64/assembler/errors.dart';
import 'package:dax64/assembler/parser/operand_parser.dart';
import 'package:dax64/assembler/parser/parser.dart';
import 'package:dax64/models/asm_program.dart';
import 'package:dax64/models/generated/index.dart';
import 'package:dax64/utils/hex8bit.dart';

import '../models/statement/assembly.dart';
import 'assembly_context.dart';

class Assembler {
  final Opcodes opcodes;
  final Map<String, Instruction> opcodeMap = {};

  Assembler({required this.opcodes}) {
    for (var instruction in opcodes.instructions) {
      opcodeMap[instruction.instruction] = instruction;
    }
  }

  Uint8List assemble(String input) {
    final config = AssemblerConfig(opcodes: opcodes);
    final program = Parser(config: config).parse(input);

    // We need to go through program twice as with first parsing round
    // we can't resolve all labels. Especially references to labels that
    // are defined later than reference cause this need.

    final bytes = secondRoundAssemble(program, config);

    return Uint8List.fromList(bytes);
  }

  List<int> secondRoundAssemble(AsmProgram program, AssemblerConfig config) {
    int defaultMemoryAddress = config.getDefaultStartingMemoryAddress();
    
    // Make sure blocks are in order, collects blocks and sort into order
    // Note that in the end resulting memoryBlocks (in future there can be
    // several) need to be continuous. 
    
    final blocks = filterAndSortBlocks(
        program, 
        defaultMemoryAddress);

    var context = AssemblyContext.newInstance(
        currentMemoryAddress: blocks[0].memoryAddress!,
        labels: program.labels.map((labelName, line) => MapEntry(labelName, Label(name: labelName, memoryAddress: null))),
        variables: program.variables,
        macros: program.macros);

    // TBD later impl support for multiple output blocks
    // TBD finally when supporting multiple blocks check also overlap of blocks

    // each 'int' represent as single byte
    final bytes = <int>[];

    for (final block in blocks) {
      if (context.currentMemoryAddress <= 0XFF) {
        // block starts from zero page
        // TBD done support for zero page labels
        throw NotImplementedAssemblerError(
            "Zero page assembling not yet supported");
      }

      // Assembling logic:
      //
      // Cases:
      // a: If label ref is known -> assembly can insert memory address
      //
      // b: If not known...
      // b1: We have resolved the zero page => all labels need to be 2 bytes
      //      -> Reserve 2 bytes
      //      -> But label to "not-resolved" table to be handled later
      //      -> Later when we encounter a new label, check table and
      //         if exists then resolve label and remove from a list
      //
      // b2: We are on zero page, or we are not sure if we have exceeded that
      //     because we don't know exact address bytes
      //      -> We zero page speculated max exceeded (treating all unresolved addresses 2 bytes)
      //         We know that all addresses must be 2 bytes -> Fix zero page bytes to match that
      //      -> In 1st round parsing we know to which memory block label belongs,
      //         if its starting address is over zero page then we know it is two bytes
      //
      // c: We are on zero page, and we have unknown label...
      //      -> Zero page assembly is separate step, reserve zero page amount of
      //         bytes
      //      -> When unknown label is encountered then reserve two bytes from table
      //         and put label to delayed resolve table
      //      -> When label on zero page is encountered, check delayed resolve table.
      //          * Place one byte to assembled bytes table
      //          * Put address of second byte to list of "ignored bytes"
      //          * Increase memory address offset that will be subtracted from
      //            running current memory address for zero page labels
      //      -> Again when zero page top address is reached
      //          * Either we have no delayed labels to resolve
      //          * Or if we have we know they will take two bytes
      //

      // NOTE: Now with current impl zero block considered as handled,
      //       => all labels refer to 16bit addresses
      //       => label offset not yet needed, but have it already
      var labelAddressOffset = 0;

      // collect labels whose addresses are not yet known, but has a place in
      // output 'bytes'
      final Map<LabelName, List<LabelAddress>> delayedLabels = HashMap();

      for (final assembly in block.assemblies) {
        final assembled = assembly.assemble(context);
        final assembledBytes = assembled.bytes;

        for (final newKnownLabel in assembled.resolvedLabels.keys) {
          // here is difference: in 'bytes' each index is one byte, but with
          // address int can present either one or two bytes
          final newKnownLabelAddress = assembled.resolvedLabels[newKnownLabel]!;

          if (delayedLabels.containsKey(newKnownLabel)) {
            for (final delayedLabelIndex in delayedLabels[newKnownLabel]!) {
              // NOTE at this point we are assuming all label are 16bit
              bytes[delayedLabelIndex] = newKnownLabelAddress & 0xFF;
              // TeroV we need to have as test that verifies byte order goes right
              bytes[delayedLabelIndex + 1] = newKnownLabelAddress & 0xFF00;
            }
            delayedLabels.remove(newKnownLabel);
          }
        }

        // as delayed labels in assembled are referring to index within returned
        // bytes, we need to map indexes used in 'bytes'
        for (final newDelayedLabel in assembled.delayedLabels.keys) {
          final newDelayedLabelIndexes = assembled.delayedLabels[newDelayedLabel]!;
          for (final delayedLabelIndex in newDelayedLabelIndexes) {
            final delayedLabelAddrIndex = context.currentMemoryAddress + delayedLabelIndex;
            delayedLabels.putIfAbsent(newDelayedLabel, () => []).add(delayedLabelAddrIndex);
          }
        }

        context = context.updateCopy(
            currentMemoryAddress_: context.currentMemoryAddress - labelAddressOffset + assembledBytes.length,
            resolvedLabels: assembled.resolvedLabels);

        // validate incoming byte values
        for (var b in assembledBytes) {
          if (b < 0) {
            throw InternalAssemblerError("Assembled byte can't be less than 0");
          }
          if (b > 0xFF) {
            throw InternalAssemblerError("Assembled byte can't be greater than 0xFF");
          }
        }
        bytes.addAll(assembledBytes);
      }

      // TeroV logic of following needs to be moved to assembly or lower...
      //   try {
      //     switch (line.statement) {
      //       case final AssemblyStatement statement:
      //         var statementBytes =
      //             assembleAssemblyStatement(statement, context);
      //         bytes.addAll(statementBytes);
      //         break;
      //
      //       case final MacroStatement _:
      //         throw UnimplementedError('Macro statements not yet implemented');
      //
      //       // plain labels do not generate any assembly output
      //       case final LabelStatement _:
      //       case final EmptyStatement _:
      //       default:
      //         // empty statements do not generate any assembly output
      //         continue;
      //     }
      //   } catch (e, stacktrace) {
      //     // TODO with verbose flag print stacktrace
      //     print(e);
      //     print(stacktrace);
      //
      //     throw AssemblerError(
      //         'Error on line ${line.lineNumber}: ${line.originalLine}. $e');
      //   }
      // }
    }

    return bytes;
  }

  ///
  List<AsmBlock> filterAndSortBlocks(AsmProgram program, int defaultStartingMemoryAddress) {
    // it could be that all blocks have memory address defined but if not then
    // we use for one a default address.
    
    final blocks = program.files
        .fold(<AsmBlock>[], (list, file) {
          list.addAll(file.blocks);
          return list;
        })
        .where((b) => b.hasDefinedAddress())
        .map((b) {
          if (b.hasRelativeAddress()) {
            return b.makeCopy(defaultStartingMemoryAddress);
          }
          return b;
        }).toList();
    
    blocks
        .sort((a, b) => a.memoryAddress! - b.memoryAddress!);
    
    blocks.reduce((a, b) {
      if (a.hasUndefinedAddress()) {
        throw AssemblerError("Unexpected undefined address for asm block");
      }
      
      if (a.hasRelativeAddress()) {
        throw AssemblerError("Unexpected relative address for asm block");
      }
        
      if (a.memoryAddress == b.memoryAddress) {
        throw AssemblerError("Two blocks have same starting memory address: ${a.memoryAddress}");
      }
      
      return b;
    });

    return blocks;
  }

  ///
  List<int> assembleAssemblyStatement(
      Assembly assembly, AssemblyContext context) {

    final AssemblyStatement statement;

    if (!statement.shouldAssemble) return [];
    final bytes = <int>[];

    switch (statement) {
      case AssemblyInstruction(
          :final opcode,
          :final instructionSpec,
          :var operand
        ):
        bytes.add(parse8BitHex(opcode.opcode));

        // operand may refer to macro or label, so resolve those
        operand = operand.resolve(context);

        xxx TeroV because opcode may change based on whether resolved operand is zeropage or 2 byte label we can't know it before hand'
        // TeroV move to common place
        var expectedAddressingMode = opcode.map((opcode) => addressingModes[opcode.addressMode]).toList();

        // special case for relative addressing mode
        if (isRelativeJumpInstruction(instructionSpec) &&
            operand.getAddressingMode() == AddressingMode.absolute) {
          throw NotImplementedAssemblerError(
              'Relative addressing mode not implemented for instruction: ${instructionSpec.instruction}');
        }

        final operandBytes =
            parseOperandValue(operand);

        bytes.addAll(operandBytes);

        break;

      case AssemblyInstruction(:var opcode):
        // no operands
        // TODO "opcode"*2 is not the naming BEST
        bytes.add(parse8BitHex(opcode.opcode));
        break;

      case final AssemblyData _:
        break;

      default:
        break;
    }

    return bytes;
  }

  bool isRelativeJumpInstruction(Instruction instruction) {
    return instruction.opcodes
        .every((element) => element.addressMode.endsWith("Rela"));
  }
}



