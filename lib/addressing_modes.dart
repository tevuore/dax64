import 'dart:typed_data';

import 'package:c64/utils/hex8bit.dart';

enum AddressingMode {
  absolute,
  absoluteX,
  absoluteY,
  accumulator,
  immediate,
  implied,
  indirect,
  indirectX,
  indirectY,
  relative,
  zeropage,
  zeropageX,
  zeropageY
}

const addressingModes = {
  'A': AddressingMode.accumulator,
  'abs': AddressingMode.absolute,
  'abs,X': AddressingMode.absoluteX,
  'abs,Y': AddressingMode.absoluteY,
  '#': AddressingMode.immediate,
  'impl': AddressingMode.implied,
  '(ind)': AddressingMode.indirect,
  '(ind,X)': AddressingMode.indirectX,
  '(ind),Y': AddressingMode.indirectY,
  'rel': AddressingMode.relative,
  'zp': AddressingMode.zeropage,
  'zp,X': AddressingMode.zeropageX,
  'zp,Y': AddressingMode.zeropageY,
};

bool areSameAddressingModes(String a, AddressingMode b) {
  switch (a) {
    case 'Accumulator':
      return b == AddressingMode.accumulator;
    case 'Immediate':
      return b == AddressingMode.immediate;
    case 'Implied':
      return b == AddressingMode.implied;
    case '"Bit 0 - Zero Page, Relative':
    case '"Bit 1 - Zero Page, Relative':
    case '"Bit 2 - Zero Page, Relative':
    case '"Bit 3 - Zero Page, Relative':
    case '"Bit 4 - Zero Page, Relative':
    case '"Bit 5 - Zero Page, Relative':
    case '"Bit 6 - Zero Page, Relative':
    case '"Bit 7 - Zero Page, Relative':
      return b == AddressingMode.relative;
    case 'Absolute':
      return b == AddressingMode.absolute;
    case 'Absolute, X':
      return b == AddressingMode.absoluteX;
    case 'Absolute, Y':
      return b == AddressingMode.absoluteY;
    case '(Indirect)':
      return b == AddressingMode.indirect;
    case '(Indirect, X)':
      return b == AddressingMode.indirectX;
    case '(Indirect), Y':
      return b == AddressingMode.indirectY;
    case 'Zero Page':
      return b == AddressingMode.zeropage;
    case 'Zero Page, X':
      return b == AddressingMode.zeropageX;
    case 'Zero Page, Y':
      return b == AddressingMode.zeropageY;
    default:
      throw Exception('Unknown address mode: $a');
  }
}

(AddressingMode, Uint8List) parseOperands(String input) {
  final data = input.trim();
  if (data.isEmpty) {
    return (AddressingMode.implied, Uint8List.fromList([]));
  }
  if (data == 'A') {
    return (AddressingMode.accumulator, Uint8List.fromList([]));
  }
  var regex = RegExp(r'^#\$([0-9A-Fa-f]{1,2})$');
  var match = regex.firstMatch(data);
  if (match != null) {
    return (
      AddressingMode.immediate,
      Uint8List.fromList([parse8BitHex(match.group(1)!)]),
    );
  }

  regex = RegExp(r'^\$([0-9A-Fa-f]{4})$');
  match = regex.firstMatch(data);
  if (match != null) {
    return (
      AddressingMode.absolute,
      parse16BitHex(match.group(1)!),
    );
  }

  regex = RegExp(r'^\$([0-9A-Fa-f]{4}),[xX]$');
  match = regex.firstMatch(data);
  if (match != null) {
    return (
      AddressingMode.absoluteX,
      parse16BitHex(match.group(1)!),
    );
  }

  regex = RegExp(r'^\$([0-9A-Fa-f]{4}),[yY]$');
  match = regex.firstMatch(data);
  if (match != null) {
    return (
      AddressingMode.absoluteY,
      parse16BitHex(match.group(1)!),
    );
  }

  regex = RegExp(r'^\(\$([0-9A-Fa-f]{4})\)$');
  match = regex.firstMatch(data);
  if (match != null) {
    return (
      AddressingMode.indirect,
      parse16BitHex(match.group(1)!),
    );
  }

  regex = RegExp(r'^\$([0-9A-Fa-f]{1,2})$');
  match = regex.firstMatch(data);
  if (match != null) {
    return (
      AddressingMode.zeropage,
      Uint8List.fromList([parse8BitHex(match.group(1)!)]),
    );
  }

  regex = RegExp(r'^\$([0-9A-Fa-f]{1,2}),[xX]$');
  match = regex.firstMatch(data);
  if (match != null) {
    return (
      AddressingMode.zeropageX,
      Uint8List.fromList([parse8BitHex(match.group(1)!)]),
    );
  }

  regex = RegExp(r'^\$([0-9A-Fa-f]{1,2}),[yY]$');
  match = regex.firstMatch(data);
  if (match != null) {
    return (
      AddressingMode.zeropageY,
      Uint8List.fromList([parse8BitHex(match.group(1)!)]),
    );
  }

  regex = RegExp(r'^\(\$([0-9A-Fa-f]{1,2}),[xX]\)$');
  match = regex.firstMatch(data);
  if (match != null) {
    return (
      AddressingMode.indirectX,
      Uint8List.fromList([parse8BitHex(match.group(1)!)]),
    );
  }

  regex = RegExp(r'^\(\$([0-9A-Fa-f]{1,2})\),[yY]$');
  match = regex.firstMatch(data);
  if (match != null) {
    return (
      AddressingMode.indirectY,
      Uint8List.fromList([parse8BitHex(match.group(1)!)]),
    );
  }

  // TODO: missing X-Indexed Zero Page Indirect
  // TODO: missing Y-Indexed Zero Page Indirect
  throw Exception('Invalid addressing mode: $data');
}
