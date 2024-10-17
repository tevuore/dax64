import 'dart:typed_data';

import '../../assembler/errors.dart';
import '../../utils/hex8bit.dart';

abstract class OperandValue {
  bool isEmpty();

  bool isHexValue();

  Uint8List toBytes();

  String getValue();

  int getIntValue();

  static build(String? value) {
    if (value == null || value.trim().isEmpty) {
      return EmptyOperandValue();
    }

    if (checkIsHexValue(value)) {
      return HexOperandValue.build(value);
    }

    throw NotImplementedAssemblerError('Operand is not empty nor hex value');
  }
}

class EmptyOperandValue extends OperandValue {
  @override
  bool isEmpty() => true;

  @override
  bool isHexValue() => false;

  @override
  Uint8List toBytes() {
    return Uint8List(0);
  }

  @override
  String getValue() {
    return '';
  }

  @override
  int getIntValue() =>
      throw AssemblerError("Empty operand value can't be converted to int");
}

class HexOperandValue extends OperandValue {
  final String _rawValue;
  final int _value;
  final Uint8List _bytes;

  HexOperandValue.build(String value)
      : _rawValue = value,
        _value = parseAsmHex(value),
        _bytes = parseHex(value);

  @override
  bool isEmpty() => false;

  @override
  bool isHexValue() => true;

  @override
  Uint8List toBytes() => _bytes;

  @override
  String getValue() => _rawValue;

  @override
  int getIntValue() => _value;
}
