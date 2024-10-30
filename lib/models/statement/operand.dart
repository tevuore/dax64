import 'dart:typed_data';

import '../../assembler/assembly_context.dart';
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

class IntegerOperandValue extends OperandValue {
  final String _rawValue;
  final int _value;
  final Uint8List _bytes;

  IntegerOperandValue(this._rawValue, this._value, this._bytes);

  factory IntegerOperandValue.build(int value) {
    Uint8List bytes;
    if (value <= 0xFF) {
      bytes = Uint8List.fromList([value]);
    } if (value <= 0xFFFF) {
      bytes = Uint8List.fromList([value | 0xFF, value | 0xFF00]);
    } else {
      throw AssemblerError("Invalid operand value: $value");
    }

    return IntegerOperandValue(value.toString(), value, bytes);
  }

  @override
  bool isEmpty() => false;

  // TeroV what is meaning of this?
  @override
  bool isHexValue() => false;

  @override
  Uint8List toBytes() => _bytes;

  @override
  String getRawValue() => _rawValue;

  @override
  int getIntValue() => _value;
}

// TeroV eventually when we have LateAssembly, do we need to extend OperandValue as parent class functions really don't make difference...
class RefOperandValue extends OperandValue {
  final String _rawValue;

  RefOperandValue(this._rawValue);

  factory RefOperandValue.build(String value) {
    // value is either ref to variable or label

    // TBD add some kind label and/or variable validation

    // TBD we would need to support simple operations, like + and -,
    // or < and > to select upper and higher byte from variable
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

  OperandValue resolve(AssemblyContext context) {
    final label = context.label(_rawValue);
    if (label != null) {
      // there exists such label, but it might be that is memory address
      // is not yet known
      if (label.memoryAddress != null) {
        return IntegerOperandValue.build(label.memoryAddress!);
      } else {
        xxx not able to resolve

        xxx return unresolved label => how resolve that later, i.e. delayed label
      }
    }

    final variable = context.variable(_rawValue);
    if (variable != null) {
      return IntegerOperandValue.build(variable.value)
    }
  }
}
