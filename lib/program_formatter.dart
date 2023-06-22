import 'dart:typed_data';

import 'package:c64/models/generated/opcodes.dart';
import 'package:c64/models/instruction.dart';

class ProgramFormatter {
  static String format(Program program) {
    final buffer = StringBuffer();
    for (var instruction in program.instructions) {
      buffer.write(instruction.instruction.instruction);

      final String addressMode =
          outputWithAddressMode(instruction.opcode, instruction.paramBytes);
      if (addressMode.isNotEmpty) {
        buffer.write(' $addressMode');
      }

      buffer.write('\n');
    }
    return buffer.toString();
  }
}

String outputWithAddressMode(Opcode opcode, Uint8List paramBytes) {
  if (paramBytes.isEmpty) {
    return '';
  }

  // TODO could we have address mode as enum?
  // TODO bytes and cycles could be ints

  switch (opcode.addressMode) {
    case 'Accumulator':
      return 'A';
    case 'Immediate':
      return '#${byteToString(paramBytes[0])}';
    case 'Implied':
      throw Exception('Implied address mode should not be formatted');
    case 'Relative':
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
    case '(Indirect, Y)':
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
