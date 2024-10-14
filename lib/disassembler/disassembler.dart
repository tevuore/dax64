import 'dart:typed_data';

import 'package:dax64/assembler/errors.dart';
import 'package:dax64/models/disasm_program.dart';
import 'package:dax64/models/generated/opcodes.dart';
import 'package:dax64/utils/hex8bit.dart';

class Disassembler {
  final Opcodes opcodes;
  final Map<int, Instruction> opcodeMap = {};

  Disassembler({required this.opcodes}) {
    for (var instruction in opcodes.instructions) {
      for (var opcode in instruction.opcodes) {
        // one instruction can have multiple opcodes
        opcodeMap[parse8BitHex(opcode.opcode)] = instruction;
      }
    }
  }

  DisasmProgram disassemble(Uint8List bytes) {
    final program = DisasmProgram();
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
      // TODO this used old style of constructing program, refactor to new style
      program.instructions.add(InstructionInstance(
          instruction: instruction,
          opcode: opcodeObj,
          instructionBytes: Uint8List.fromList(operands)));

      i += numberOfParamBytes + 1;
    }

    return program;
  }
}
