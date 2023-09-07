import 'dart:typed_data';

import 'package:dax64/assembler/addressing_modes.dart';
import 'package:dax64/assembler/errors.dart';
import 'package:dax64/assembler/parser.dart';
import 'package:dax64/models/asm_program.dart';
import 'package:dax64/models/generated/index.dart';
import 'package:dax64/utils/hex8bit.dart';

class Assembler {
  final Opcodes opcodes;
  final Map<String, Instruction> opcodeMap = {};

  Assembler({required this.opcodes}) {
    for (var instruction in opcodes.instructions) {
      opcodeMap[instruction.instruction] = instruction;
    }
  }

  Uint8List assemble(String input) {
    final program = Parser(opcodes: opcodes).parse(input);

    final bytes = <int>[];

    // we need to go through program twice
    //  - 1st round to find all labels and macro statement (TODO impl)
    //  - 2nd round to expand lab

    // TODO first round here

    // TODO at first stage support just assembly statements
    //  - at 2nd phase data blocks
    //  - then macros
    // TODO final plan!!
    //  1) go through to find all assignments and labels (and later macros)
    //  2) then expand values and parse operands
    //  3) then assemble

    // 2nd round
    for (final block in program.blocks) {
      for (final line in block.lines) {
        try {
          switch (line.statement) {
            case final AssemblyStatement statement:
              var statementBytes = assembleAssemblyStatement(statement);
              bytes.addAll(statementBytes);
              break;

            case final MacroStatement _:
              throw UnimplementedError('Macro statements not yet implemented');

            case final EmptyStatement _:
              // empty statements do not generate any assembly output
              continue;
          }
        } catch (e, stacktrace) {
          // TODO with verbose flag print stacktrace
          print(e);
          print(stacktrace);

          throw AssemblerError(
              'Error on line ${line.lineNumber}: ${line.originalLine}. $e');
        }
      }
    }

    return Uint8List.fromList(bytes);
  }

  List<int> assembleAssemblyStatement(AssemblyStatement statement) {
    final bytes = <int>[];
    // TeroV functional way
    if (statement is AssemblyInstruction) {
      // TeroV this could be done in functional way

      if (statement.shouldAssemble) {
        if (statement.operand != null) {
          bytes.add(parse8BitHex(statement.opcode.opcode));

          // operand value is string - it could be label or macro ref, but
          // that is not yet implemented for assembling output

          // TODO why opcode has addressing mode as string? could it have as enum?
          // special case for relative addressing mode
          if (isRelativeJumpInstruction(statement.instructionSpec) &&
              statement.operand!.addressingMode == AddressingMode.absolute) {
            throw NotImplementedAssemblerError(
                'Relative addressing mode not implemented for instruction: ${statement.instructionSpec.instruction}');
          }

          // TODO not nicest way to force non null
          final operandBytes = parseOperandValue(
              statement.operand!.addressingMode, statement.operand!.value);
          bytes.addAll(operandBytes);
        } else {
          // no operands
          // TODO is the naming BEST
          bytes.add(parse8BitHex(statement.opcode.opcode));
        }
      }
    }

    return bytes;
  }

  bool isRelativeJumpInstruction(Instruction instruction) {
    return instruction.opcodes
        .every((element) => element.addressMode.endsWith("Rela"));
  }
}
