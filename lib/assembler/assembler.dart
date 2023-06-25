import 'dart:typed_data';

import 'package:c64/assembler/addressing_modes.dart';
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
    final bytes = <int>[];
    final lines = input.split('\n');
    for (var line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) {
        continue;
      }
      final parts = trimmedLine
          .split(';'); // TODO this logic does not support multiple comments
      final commandPart = parts[0].trim(); // TODO test plain command line

      // only comment line?
      if (commandPart.isEmpty) {
        continue;
      }

      final commandParts =
          commandPart.split(' '); // TODO: does not support optional whitespace
      final instruction = commandParts[0].toUpperCase();
      final instructionObj = opcodeMap[instruction];
      if (instructionObj == null) {
        throw Exception('Unknown instruction: $instruction');
      }

      if (commandParts.length > 1) {
        final (opcodeObj, operandBytes) =
            extractOperands(instructionObj, commandParts[1]);
        bytes.add(parse8BitHex(opcodeObj.opcode));
        bytes.addAll(operandBytes);
      } else {
        // no operands
        final opcodeObj = instructionObj.opcodes
            .firstWhere((element) => element.bytes.length == 1);

        bytes.add(parse8BitHex(opcodeObj.opcode));
      }
    }
    return Uint8List.fromList(bytes);
  }

  (Opcode, Uint8List) extractOperands(Instruction instruction, String input) {
    final (addressingMode, operandBytes) = parseOperands(input);

    // special case for relative addressing mode
    if (isRelativeJumpInstruction(instruction) &&
        addressingMode == AddressingMode.absolute) {
      throw Exception(
          'Relative addressing mode not implemented for instruction: ${instruction.instruction}');
      // return (AddressingMode.relative, Uint8List.fromList([operandBytes[1]]));
    }

    return (
      instruction.opcodes.firstWhere((element) =>
          areSameAddressingModes(element.addressMode, addressingMode)),
      operandBytes
    );
  }

  bool isRelativeJumpInstruction(Instruction instruction) {
    return instruction.opcodes
        .every((element) => element.addressMode.endsWith("Rela"));
  }
}

// special case for relative addressing mode
