import 'dart:typed_data';

import 'package:c64/models/instruction.dart';
import 'package:c64/utils/hex8bit.dart';

class HexFormatter {
  static String format(Uint8List bytes) {
    List<String> hexCodes = bytes.map((number) => uint8ToHex(number)).toList();

    return hexCodes.join(' ');
  }

  static Uint8List formatToBytes(Program program) {
    final buffer = Uint8List(program.instructions.length * 3);

    for (var instruction in program.instructions) {
      buffer.add(parse8BitHex(instruction.opcode.opcode));
      if (instruction.paramBytes.isNotEmpty) {
        if (instruction.paramBytes.length == 1) {
          buffer.add(instruction.paramBytes[0]);
        }
        if (instruction.paramBytes.length > 1) {
          buffer.add(instruction.paramBytes[1]);
          buffer.add(instruction.paramBytes[0]);
        }
      }
    }
    return buffer;
  }
}
