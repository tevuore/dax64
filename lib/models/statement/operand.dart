import 'dart:typed_data';

import '../../assembler/errors.dart';
import '../../utils/hex8bit.dart';

abstract class OperandValue {
  bool isEmpty();

  bool isHexValue();

  Uint8List toBytes();

  String getRawValue();

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

// TeroV should operand related classes be under operand file?
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
  String getRawValue() {
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

  HexOperandValue(this._rawValue, this._value, this._bytes);

  factory HexOperandValue.build(String value) {
    return HexOperandValue(value, parseAsmHex(value), parseHex(value));
  }

  static HexOperandValue? tryParse(String value) {
    try {
      return HexOperandValue.build(value);
    } on FormatException catch (_) {
      return null;
    }
  }

  @override
  bool isEmpty() => false;

  @override
  bool isHexValue() => true;

  @override
  Uint8List toBytes() => _bytes;

  @override
  String getRawValue() => _rawValue;

  @override
  int getIntValue() => _value;
}

class RefOperandValue extends OperandValue {
  final String _rawValue;

  RefOperandValue(this._rawValue);

  factory RefOperandValue.build(String value) {
    // value is either ref to variable or label

    // TeroV add some kind label and/or variable validation

    // FUTURE: we would need to support simple operations, like + and -
    return RefOperandValue(value);
  }

  @override
  bool isEmpty() => false;

  @override
  bool isHexValue() => false;

  @override
  Uint8List toBytes() => throw NotImplementedAssemblerError('ref value impl');

  @override
  String getRawValue() => _rawValue;

  @override
  int getIntValue() => throw NotImplementedAssemblerError('ref value impl');
}
