import 'dart:typed_data';

import '../../models/statement/operand.dart';
import '../addressing_modes.dart';
import '../assembly.dart';
import '../errors.dart';

// TeroV if output is ref value then Addressing mode is just a hint...
(AddressingMode, OperandValue) parseOperands(String input) {
  final data = input.trim();
  if (data.isEmpty) {
    return (AddressingMode.implied, EmptyOperandValue());
  }
  if (data == 'A') {
    return (AddressingMode.accumulator, EmptyOperandValue());
  }

  var regex = RegExp(r'^#(\$?[0-9A-Za-z_]+)$');
  var match = regex.firstMatch(data);
  if (match != null) {
    return (
      AddressingMode.immediate,
      buildValueRefOperandValue(match.group(1)!)
    );
  }

  regex = RegExp(r'^(\$?[0-9A-Fa-f]{1,2})$');
  match = regex.firstMatch(data);
  if (match != null) {
    return (
      AddressingMode.zeropage,
      buildValueRefOperandValue(match.group(1)!)
    );
  }

  regex = RegExp(r'^(\$?[0-9A-Fa-f]{1,2}),[xX]$');
  match = regex.firstMatch(data);
  if (match != null) {
    return (
      AddressingMode.zeropageX,
      buildValueRefOperandValue(match.group(1)!)
    );
  }

  regex = RegExp(r'^(\$?[0-9A-Fa-f]{1,2}),[yY]$');
  match = regex.firstMatch(data);
  if (match != null) {
    return (
      AddressingMode.zeropageY,
      buildValueRefOperandValue(match.group(1)!)
    );
  }

  regex = RegExp(r'^\((\$?[0-9A-Za-z_]+),[xX]\)$');
  match = regex.firstMatch(data);
  if (match != null) {
    return (
      AddressingMode.indirectX,
      buildValueRefOperandValue(match.group(1)!)
    );
  }

  regex = RegExp(r'^\((\$?[0-9A-Za-z_]+)\),[yY]$');
  match = regex.firstMatch(data);
  if (match != null) {
    return (
      AddressingMode.indirectY,
      buildValueRefOperandValue(match.group(1)!)
    );
  }

  regex = RegExp(r'^(\$?[0-9A-Za-z_]+)$');
  match = regex.firstMatch(data);
  if (match != null) {
    return (
      AddressingMode.absolute,
      buildAddressRefOperandValue(match.group(1)!)
    );
  }

  regex = RegExp(r'^(\$?[0-9A-Za-z_]+),[xX]$');
  match = regex.firstMatch(data);
  if (match != null) {
    return (
      AddressingMode.absoluteX,
      buildValueRefOperandValue(match.group(1)!)
    );
  }

  regex = RegExp(r'^(\$?[0-9A-Za-z_]+),[yY]$');
  match = regex.firstMatch(data);
  if (match != null) {
    return (
      AddressingMode.absoluteY,
      buildAddressRefOperandValue(match.group(1)!)
    );
  }

  regex = RegExp(r'^\((\$?[0-9A-Za-z_]+)\)$');
  match = regex.firstMatch(data);
  if (match != null) {
    return (
      AddressingMode.indirect,
      buildAddressRefOperandValue(match.group(1)!)
    );
  }

  // TODO: missing X-Indexed Zero Page Indirect
  // TODO: missing Y-Indexed Zero Page Indirect
  throw Exception('Invalid addressing mode: $data');
}

// TODO could we pass full operand?
/// convert operand value to bytes
/// TODO input is assumed to be hex value
Uint8List parseOperandValue(Operand operand) {
  assert(operand.isResolved());
  final addressingMode = operand.getAddressingMode();
  final input = operand.getValue();

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

OperandValue buildAddressRefOperandValue(String rawValue) {
  // TeroV add validation?

  final hexValue = HexOperandValue.tryParse(rawValue);
  if (hexValue != null) return hexValue;

  final integerValue = IntegerOperandValue.tryParse(rawValue);
  if (integerValue != null) return integerValue;

  // it must be label or variable ref, we can't distinguish which one

  return RefOperandValue.build(rawValue);
}

OperandValue buildValueRefOperandValue(String rawValue) {
  // TeroV add validation, value ref needs to refer to two bytes
  //       so value itself if directly defined can't be over two bytes length

  if (rawValue.startsWith(r'$')) {
    final hexValue = HexOperandValue.tryParse(rawValue);
    // TODO validate; value needs to always < 0xFF
    if (hexValue != null) return hexValue;
    throw AssemblerError('Invalid hex value: $rawValue');
  }

  // it must be zero page label or variable ref, we can't distinguish which one
  return RefOperandValue.build(rawValue);
}
