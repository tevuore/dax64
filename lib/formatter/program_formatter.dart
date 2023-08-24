import 'dart:typed_data';

import 'package:dax64/formatter/hex_formatter.dart';
import 'package:dax64/models/generated/opcodes.dart';
import 'package:dax64/models/instruction.dart';
import 'package:dax64/utils/hex8bit.dart';

const commentStartingColumn = 15;

class ProgramFormatter {
  static String format(Program program,
      {bool addInstructionDescription = false, bool addBytes = false}) {
    final buffer = StringBuffer();
    for (var instruction in program.instructions) {
      final lineBuff = StringBuffer();

      if (addBytes) {
        final allBytes = <int>[];
        allBytes.add(parse8BitHex(instruction.opcode.opcode));
        allBytes.addAll(instruction.paramBytes);

        String hex = HexFormatter.format(Uint8List.fromList(allBytes));
        lineBuff.write(hex.padRight(9, ' '));
      }

      lineBuff.write(instruction.instruction.instruction);

      final String addressMode =
          outputWithAddressMode(instruction.opcode, instruction.paramBytes);
      if (addressMode.isNotEmpty) {
        lineBuff.write(' $addressMode');
      }

      if (addInstructionDescription) {
        lineBuff.write(
            '${''.padLeft(commentStartingColumn - lineBuff.length, ' ')}; ${instruction.instruction.description}');
      }

      buffer.write(lineBuff.toString());
      buffer.write('\n');
    }
    return buffer.toString();
  }
}

String outputWithAddressMode(Opcode opcode, Uint8List paramBytes) {
  if (paramBytes.isEmpty) {
    return '';
  }

  // TODO could we have address mode as enum? check lib
  // TODO bytes and cycles could be ints -> in conversion script

  switch (opcode.addressMode) {
    case 'Accumulator':
      return 'A';
    case 'Immediate':
      return '#${byteToString(paramBytes[0])}';
    case 'Implied':
      throw Exception('Implied address mode should not be formatted');
    case '"Bit 0 - Zero Page, Relative':
    case '"Bit 1 - Zero Page, Relative':
    case '"Bit 2 - Zero Page, Relative':
    case '"Bit 3 - Zero Page, Relative':
    case '"Bit 4 - Zero Page, Relative':
    case '"Bit 5 - Zero Page, Relative':
    case '"Bit 6 - Zero Page, Relative':
      if (paramBytes.length != 1) {
        throw Exception('Relative address mode should have 1 bytes');
      }
      return '${byteToString(paramBytes[0])}00';
    case 'Absolute':
      return bytesToAddress(paramBytes);
    case 'Absolute, X':
      return '${bytesToAddress(paramBytes)},x';
    case 'Absolute, Y':
      return '${bytesToAddress(paramBytes)},y';
    case '(Indirect)':
      return '(${bytesToAddress(paramBytes)})';
    case '(Indirect, X)':
      return '(${bytesToAddress(paramBytes)}),x';
    case '(Indirect), Y':
      return '(${bytesToAddress(paramBytes)}),y';
    case 'Zero Page':
      return byteToString(paramBytes[0]);
    case 'Zero Page, X':
      return '${byteToString(paramBytes[0])},x';
    case 'Zero Page, Y':
      return '${byteToString(paramBytes[0])},y';
    default:
      throw Exception('Unknown address mode: ${opcode.addressMode}');
  }
}

String byteToString(int byte) {
  return '\$${byteToHex(byte)}';
}

String byteToHex(int byte) {
  return byte.toRadixString(16).padLeft(2, '0');
}

String bytesToAddress(Uint8List bytes) {
  if (bytes.length != 2) {
    throw Exception('Address should have 2 bytes');
  }
  // note correct order
  return '\$${byteToHex(bytes[1])}${byteToHex(bytes[0])}';
}
