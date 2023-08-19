// TODO could we have attribute that defines whether operand bytes should be expected?
import 'dart:typed_data';

import 'package:c64/assembler/errors.dart';
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

(AddressingMode, String) parseOperands(String input) {
  final data = input.trim();
  if (data.isEmpty) {
    return (AddressingMode.implied, '');
  }
  if (data == 'A') {
    return (AddressingMode.accumulator, '');
  }
  var regex = RegExp(r'^#\$([0-9A-Fa-f]{1,2})$');
  var match = regex.firstMatch(data);
  if (match != null) {
    return (AddressingMode.immediate, match.group(1)!);
  }

  regex = RegExp(r'^\$([0-9A-Fa-f]{4})$');
  match = regex.firstMatch(data);
  if (match != null) {
    return (AddressingMode.absolute, match.group(1)!);
  }

  regex = RegExp(r'^\$([0-9A-Fa-f]{4}),[xX]$');
  match = regex.firstMatch(data);
  if (match != null) {
    return (AddressingMode.absoluteX, match.group(1)!);
  }

  regex = RegExp(r'^\$([0-9A-Fa-f]{4}),[yY]$');
  match = regex.firstMatch(data);
  if (match != null) {
    return (AddressingMode.absoluteY, match.group(1)!);
  }

  regex = RegExp(r'^\(\$([0-9A-Fa-f]{4})\)$');
  match = regex.firstMatch(data);
  if (match != null) {
    return (AddressingMode.indirect, match.group(1)!);
  }

  regex = RegExp(r'^\$([0-9A-Fa-f]{1,2})$');
  match = regex.firstMatch(data);
  if (match != null) {
    return (AddressingMode.zeropage, match.group(1)!);
  }

  regex = RegExp(r'^\$([0-9A-Fa-f]{1,2}),[xX]$');
  match = regex.firstMatch(data);
  if (match != null) {
    return (AddressingMode.zeropageX, match.group(1)!);
  }

  regex = RegExp(r'^\$([0-9A-Fa-f]{1,2}),[yY]$');
  match = regex.firstMatch(data);
  if (match != null) {
    return (AddressingMode.zeropageY, match.group(1)!);
  }

  regex = RegExp(r'^\(\$([0-9A-Fa-f]{1,2}),[xX]\)$');
  match = regex.firstMatch(data);
  if (match != null) {
    return (AddressingMode.indirectX, match.group(1)!);
  }

  regex = RegExp(r'^\(\$([0-9A-Fa-f]{1,2})\),[yY]$');
  match = regex.firstMatch(data);
  if (match != null) {
    return (AddressingMode.indirectY, match.group(1)!);
  }

  // TODO: missing X-Indexed Zero Page Indirect
  // TODO: missing Y-Indexed Zero Page Indirect
  throw Exception('Invalid addressing mode: $data');
}

// TODO could we pass full operand?
/// convert operand value to bytes
/// TODO input is assumed to be hex value
Uint8List parseOperandValue(AddressingMode addressingMode, String? input) {
  switch (addressingMode) {
    case AddressingMode.implied:
    case AddressingMode.accumulator:
      return Uint8List.fromList([]);

    case AddressingMode.immediate:
    case AddressingMode.zeropage:
    case AddressingMode.zeropageX:
    case AddressingMode.zeropageY:
    case AddressingMode.indirectX:
    case AddressingMode.indirectY:
      if (input == null) {
        throw AssemblerError(
            'Addressing mode ${addressingMode.toString()} requires value but it was null ');
      }
      return Uint8List.fromList([parse8BitHex(input)]);

    case AddressingMode.absolute:
    case AddressingMode.absoluteX:
    case AddressingMode.absoluteY:
    case AddressingMode.indirect:
      if (input == null) {
        throw AssemblerError(
            'Addressing mode ${addressingMode.toString()} requires value but it was null ');
      }
      return parse16BitHex(input);

    case AddressingMode.relative:
      throw AssemblerError('Relative addressing mode not yet implemented');
  }
}
