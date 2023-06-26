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
          if (instruction.label != null) {}
        }
      }
    }

    // TODO: go through to find all assignments and labels (and later macros)

    // TODO: then expand values and parse operands

    // TODO: then assemble

    for (final ele in elements) {
      if (ele.instruction == null) {
        continue;
      }
      if (!opcodeMap.containsKey(ele.instruction)) {
        throw AssemblerError('Unknown instruction: ${ele.instruction}');
      }
      final instructionObj = opcodeMap[ele.instruction]!;

      if (ele.operand != null) {
        final (opcodeObj, operandBytes) =
            extractOperands(instructionObj, ele.operand!);
        bytes.add(parse8BitHex(opcodeObj.opcode));
        bytes.addAll(operandBytes);
      } else {
        // no operands
        final opcodeObjs = instructionObj.opcodes
            .where((element) => element.bytes.length == 1)
            .toList();
        if (opcodeObjs.isEmpty) {
          throw AssemblerError(
              'No unique implicit opcode found for instruction: ${instructionObj.instruction}');
        }
        bytes.add(parse8BitHex(opcodeObjs[0].opcode));
      }
    }

    return Uint8List.fromList(bytes);
  }

  (Opcode, Uint8List) extractOperands(Instruction instruction, String input) {
    final (addressingMode, operandBytes) = parseOperands(input);

    // special case for relative addressing mode
    if (isRelativeJumpInstruction(instruction) &&
        addressingMode == AddressingMode.absolute) {
      throw NotImplementedAssemblerError(
          'Relative addressing mode not implemented for instruction: ${instruction.instruction}');
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
