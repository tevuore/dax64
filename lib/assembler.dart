import 'dart:typed_data';

import 'package:c64/models/generated/index.dart';
import 'package:c64/opcodes_store.dart';

class Assembler {
  late Opcodes opcodes;
  final Map<String, Instruction> opcodeMap = {};

  Assembler();

  Future initialize() async {
    opcodes = await readOpcodeJsonFile(
        'data/opcodes.json'); // TODO: fix this path somewhere

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
      final parts = trimmedLine.split(' ');
      final instruction = parts[0];
      final instructionObj = opcodeMap[instruction];
      if (instructionObj == null) {
        throw Exception('Unknown instruction: $instruction');
      }
      bytes.add(int.parse(
          instructionObj.opcodes[0].opcode.replaceFirst('0x', ''), radix: 16));
      if (parts.length > 1) {
        final operands = parts[1].split(',');
        for (var operand in operands) {
          bytes.add(int.parse(operand));
        }
      }
    }
    return Uint8List.fromList(bytes);
  }
}
