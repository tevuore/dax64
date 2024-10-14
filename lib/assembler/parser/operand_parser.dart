import 'dart:typed_data';

import '../../models/statement/operand.dart';
import '../addressing_modes.dart';
import '../errors.dart';

(AddressingMode, OperandValue) parseOperands(String input) {
  final data = input.trim();
  if (data.isEmpty) {
    return (AddressingMode.implied, EmptyOperandValue());
  }
  if (data == 'A') {
    return (AddressingMode.accumulator, EmptyOperandValue());
  }
  var regex = RegExp(r'^#\$([0-9A-Fa-f]{1,2})$');
  var match = regex.firstMatch(data);
  if (match != null) {
    return (AddressingMode.immediate, HexOperandValue.build(match.group(1)!));
  }

  regex = RegExp(r'^\$([0-9A-Fa-f]{4})$');
  match = regex.firstMatch(data);
  if (match != null) {
    return (AddressingMode.absolute, HexOperandValue.build(match.group(1)!));
  }

  regex = RegExp(r'^\$([0-9A-Fa-f]{4}),[xX]$');
  match = regex.firstMatch(data);
  if (match != null) {
    return (AddressingMode.absoluteX, HexOperandValue.build(match.group(1)!));
  }

  regex = RegExp(r'^\$([0-9A-Fa-f]{4}),[yY]$');
  match = regex.firstMatch(data);
  if (match != null) {
    return (AddressingMode.absoluteY, HexOperandValue.build(match.group(1)!));
  }

  regex = RegExp(r'^\(\$([0-9A-Fa-f]{4})\)$');
  match = regex.firstMatch(data);
  if (match != null) {
    return (AddressingMode.indirect, HexOperandValue.build(match.group(1)!));
  }

  regex = RegExp(r'^\$([0-9A-Fa-f]{1,2})$');
  match = regex.firstMatch(data);
  if (match != null) {
    return (AddressingMode.zeropage, HexOperandValue.build(match.group(1)!));
  }

  regex = RegExp(r'^\$([0-9A-Fa-f]{1,2}),[xX]$');
  match = regex.firstMatch(data);
  if (match != null) {
    return (AddressingMode.zeropageX, HexOperandValue.build(match.group(1)!));
  }

  regex = RegExp(r'^\$([0-9A-Fa-f]{1,2}),[yY]$');
  match = regex.firstMatch(data);
  if (match != null) {
    return (AddressingMode.zeropageY, HexOperandValue.build(match.group(1)!));
  }

  regex = RegExp(r'^\(\$([0-9A-Fa-f]{1,2}),[xX]\)$');
  match = regex.firstMatch(data);
  if (match != null) {
    return (AddressingMode.indirectX, HexOperandValue.build(match.group(1)!));
  }

  regex = RegExp(r'^\(\$([0-9A-Fa-f]{1,2})\),[yY]$');
  match = regex.firstMatch(data);
  if (match != null) {
    return (AddressingMode.indirectY, HexOperandValue.build(match.group(1)!));
  }

  // TODO: missing X-Indexed Zero Page Indirect
  // TODO: missing Y-Indexed Zero Page Indirect
  throw Exception('Invalid addressing mode: $data');
}

// TODO could we pass full operand?
/// convert operand value to bytes
/// TODO input is assumed to be hex value
Uint8List parseOperandValue(AddressingMode addressingMode, OperandValue input) {
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
      if (input.isEmpty()) {
        throw AssemblerError(
            'Addressing mode ${addressingMode.toString()} requires value but it was null ');
      }
      return input.toBytes();

    case AddressingMode.absolute:
    case AddressingMode.absoluteX:
    case AddressingMode.absoluteY:
    case AddressingMode.indirect:
      if (input.isEmpty()) {
        throw AssemblerError(
            'Addressing mode ${addressingMode.toString()} requires value but it was null ');
      }
      var bytes = input.toBytes();
      if (bytes.lengthInBytes < 2) {
        throw AssemblerError('Expected 16 bit value but got 8 bit');
      }
      return input.toBytes();

    case AddressingMode.relative:
      throw AssemblerError('Relative addressing mode not yet implemented');
  }
}
