import 'package:dax64/assembler/errors.dart';
import 'package:dax64/models/generated/opcodes.dart';

// TODO is this good name, or should be instruction set? Or would it be subobject?
class AssemblerConfig {
  final Map<String, Instruction> opcodeMap = {};

  AssemblerConfig({required Opcodes opcodes}) {
    for (var instruction in opcodes.instructions) {
      opcodeMap[instruction.instruction] = instruction;
    }
  }

  bool isOpcode(String input) {
    return opcodeMap.containsKey(input.toUpperCase());
  }

  // used case in opcode needs to match to registered opcodes
  Instruction getInstruction(String opcode) {
    if (!isOpcode(opcode)) {
      throw AssemblerError('Unknown instruction: $opcode');
    }
    return opcodeMap[opcode]!;
  }

  // TODO TeroV real memory address take a look from as65t
  // TODO this should be possible to override
  // TODO if overriding then raises question this config should be separate
  //      from opcode config?
  int getDefaultStartingMemoryAddress() => 0x100;
}
