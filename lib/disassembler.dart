import 'dart:typed_data';

import 'package:c64/errors.dart';
import 'package:c64/models/generated/opcodes.dart';
import 'package:c64/models/instruction.dart';
import 'package:c64/opcodes_store.dart';
import 'package:c64/utils/hex8bit.dart';

class Disassembler {
  late Opcodes opcodes;
  final Map<int, Instruction> opcodeMap = {};

  Disassembler();

  Future initialize() async {
    opcodes = await readOpcodeJsonFile('data/opcodes.json');

    for (var instruction in opcodes.instructions) {
      for (var opcode in instruction.opcodes) {
        // one instruction can have multiple opcodes
        opcodeMap[parse8BitHex(opcode.opcode)] = instruction;
      }
    }
  }

  Program disassemble(Uint8List bytes) {
    final program = Program();
    var i = 0;
    while (i < bytes.length) {
      var opcode = bytes[i];
      if (!opcodeMap.containsKey(opcode)) {
        throw AssemblerError('Unknown opcode: ${opcode.toRadixString(16)}');
      }
      var instruction = opcodeMap[opcode];
      final opcodeToLookFor = '0x${opcode.toRadixString(16).padLeft(2, '0')}';
      Opcode opcodeObj;

      // TODO smarter data structure / find
      try {
        opcodeObj = instruction!.opcodes
            .firstWhere((element) => element.opcode == opcodeToLookFor);
      } catch (e) {
        throw AssemblerError(
            'Unknown opcode when looking from catalog: $opcodeToLookFor');
      }

      final numberOfParamBytes = (int.parse(opcodeObj.bytes)) - 1;

      final List<int> operands = [];
      for (var j = 0; j < numberOfParamBytes; j++) {
        operands.add(bytes[i + j + 1]);
      }
      program.instructions.add(InstructionInstance(
          instruction: instruction,
          opcode: opcodeObj,
          instructionBytes: Uint8List.fromList(operands)));

      i += numberOfParamBytes + 1;
    }

    return program;
  }
}
