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

    for (final block in program.blocks) {
      for (final line in block.lines) {
        try {
          if (line.statement is AssemblyInstruction) {
            final instruction = line.statement as AssemblyInstruction;

            if (instruction.shouldAssemble) {
              if (instruction.operand != null) {
                bytes.add(parse8BitHex(instruction.opcode.opcode));

                // operand value is string - it could be label or macro ref, but
                // that is not yet implemented

                // TODO why opcode has addressing mode as string? could it have as enum?
                // special case for relative addressing mode
                if (isRelativeJumpInstruction(instruction.instructionSpec) &&
                    instruction.operand!.addressingMode ==
                        AddressingMode.absolute) {
                  throw NotImplementedAssemblerError(
                      'Relative addressing mode not implemented for instruction: ${instruction.instructionSpec.instruction}');
                }

                // TODO not nicest way to force non null
                final operandBytes = parseOperandValue(
                    instruction.operand!.addressingMode,
                    instruction.operand!.value);
                bytes.addAll(operandBytes);
              } else {
                // no operands
                // TODO is the naming BEST
                bytes.add(parse8BitHex(instruction.opcode.opcode));
              }
            }
          }
        } catch (e, stacktrace) {
          // TODO with verbose flag print stacktrace
          print(e);
          print(stacktrace);

          throw AssemblerError(
              'Error on line ${line.lineNumber}: ${line.originalLine}. $e');
        }
        // TODO at first stage support just assembly statements
        //  - at 2nd phase data blocks
        //  - then macros
      }
    }

    // TODO final plan!!
    //  1) go through to find all assignments and labels (and later macros)
    //  2) then expand values and parse operands
    //  3) then assemble

    return Uint8List.fromList(bytes);
  }

  bool isRelativeJumpInstruction(Instruction instruction) {
    return instruction.opcodes
        .every((element) => element.addressMode.endsWith("Rela"));
  }
}
