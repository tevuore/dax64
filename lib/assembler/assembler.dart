import 'dart:typed_data';

import 'package:c64/assembler/addressing_modes.dart';
import 'package:c64/assembler/errors.dart';
import 'package:c64/assembler/parser.dart';
import 'package:c64/models/asm_program.dart';
import 'package:c64/models/generated/index.dart';
import 'package:c64/utils/hex8bit.dart';

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

    // TODO make old behaviour working first
    //  -> bytes = assembleOld(program);

    for (final block in program.blocks) {
      for (final line in block.lines) {
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
                    'Relative addressing mode not implemented for instruction: ${instruction
                        .instructionSpec.instruction}');
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

        // TODO at first stage support just assembly statements
        // TODO at 2nd phase data blocks
        // TODO then macros
        // TODO what about plain comment lines, are they already skipped
      }
    }

    // TODO final plan!!
    // TODO: go through to find all assignments and labels (and later macros)
    // TODO: then expand values and parse operands
    // TODO: then assemble

    return Uint8List.fromList(bytes);
  }

  bool isRelativeJumpInstruction(Instruction instruction) {
    return instruction.opcodes
        .every((element) => element.addressMode.endsWith("Rela"));
  }
}
