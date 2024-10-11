import 'dart:typed_data';

import 'package:dax64/assembler/addressing_modes.dart';
import 'package:dax64/assembler/assembler_config.dart';
import 'package:dax64/assembler/errors.dart';
import 'package:dax64/assembler/parsers/parser.dart';
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
    final config = AssemblerConfig(opcodes: opcodes);
    final program = Parser(config: config).parse(input);

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

    // TODO how macro invocations is recognized and when it is expanded?

    // label points to line number because a label may me located on its own
    // line, and refers to next instructions line, or it maybe combined to
    // same line with instruction
    final labels = firstRoundCollectData(program);

    final bytes = secondRoundAssemble(program, labels);

    return Uint8List.fromList(bytes);
  }

  // collects labels
  // TODO add value object
  Map<String, AsmProgramLine> firstRoundCollectData(AsmProgram program) {
    final labels = <String, AsmProgramLine>{};

    for (final block in program.blocks) {
      for (final line in block.lines) {
        try {
          switch (line.statement) {
            case final AssemblyStatement statement:
              if (statement.hasLabel()) {
                labels[statement.label] = line;
              }
              break;

            case final MacroStatement _:
              // TODO collect macros and macro assignments
              throw UnimplementedError('Macro statements not yet implemented');

            case final LabelStatement statement:
              labels[statement.label] = line;
              break;

            case final EmptyStatement _:
              // empty statements do not contain labels, label is part of
              // AssemblyStatement
              // TODO: which above is a bit funny as line with just a label is
              // not generated to any assembly output... label should actually
              // be part of next statement...
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

    return labels;
  }

  List<int> secondRoundAssemble(
      AsmProgram program, Map<String, AsmProgramLine> labels) {
    // TODO impl using labels

    final bytes = <int>[];
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

            // plain labels do not generate any assembly output
            case final LabelStatement _:
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

    return bytes;
  }

  List<int> assembleAssemblyStatement(AssemblyStatement statement) {
    if (!statement.shouldAssemble) return [];
    final bytes = <int>[];

    switch (statement) {
      case AssemblyInstruction(
          :var opcode,
          :var instructionSpec,
          :var operand?
        ):
        bytes.add(parse8BitHex(opcode.opcode));

        // operand value is string - it could be label or macro ref, but
        // that is not yet implemented for assembling output

        // TODO why opcode has addressing mode as string? could it have as enum?
        // special case for relative addressing mode
        if (isRelativeJumpInstruction(instructionSpec) &&
            operand.addressingMode == AddressingMode.absolute) {
          throw NotImplementedAssemblerError(
              'Relative addressing mode not implemented for instruction: ${instructionSpec.instruction}');
        }

        final operandBytes =
            parseOperandValue(operand.addressingMode, operand.value);

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
