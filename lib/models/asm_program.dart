import 'dart:typed_data';

import 'package:dax64/assembler/addressing_modes.dart';
import 'package:dax64/assembler/errors.dart';
import 'package:dax64/models/generated/index.dart';
import 'package:dax64/utils/hex8bit.dart';

// TOOO how to implement as immutable?

class AsmProgram {
  final List<AsmBlock> blocks = [];
}

class AsmBlock {
  final List<AsmProgramLine> lines = [];
}

class AsmProgramLine {
  final int lineNumber;
  final String originalLine;
  final String? comment;
  final Statement statement;

  AsmProgramLine(
      {required this.lineNumber,
      required this.originalLine,
      required this.statement,
      this.comment});

  AsmProgramLine.withoutStatement(
      {required this.lineNumber, required this.originalLine, this.comment})
      : statement = EmptyStatement();
}

sealed class Statement {
  bool get shouldAssemble;
}

/// Models empty or plain comment line in assembly source code
class EmptyStatement extends Statement {
  @override
  final shouldAssemble = false;
}

class AssemblyStatement extends Statement {
  final String? label;
  int? memoryAddress; // TODO should be only in machine instructions

  @override
  final shouldAssemble = true;

  AssemblyStatement({this.label, this.memoryAddress});
}

class AssemblyInstruction extends AssemblyStatement {
  final Instruction instructionSpec;
  final Opcode opcode;
  final Operand?
      operand; // TODO shouldn't every instruction have at least place for addressing mode?

  AssemblyInstruction({
    required this.instructionSpec,
    required this.opcode,
    this.operand,
    String? label,
    int? location,
  }) : super(
          memoryAddress: location,
          label: label,
        );
}

class AssemblyData extends AssemblyStatement {
  final MacroValueType type;
  List<String> values = [];

  AssemblyData(
      {required this.type, required this.values, String? label, int? location})
      : super(
          memoryAddress: location,
          label: label,
        );
}

abstract class MacroStatement extends Statement {
  @override
  final shouldAssemble = false;
}

class MacroInstruction extends MacroStatement {
// TODO macro definition

  MacroInstruction({int? location});
}

class MacroAssignment extends MacroStatement {
  final String name;
  final String value; // TODO how to support different value types

  MacroAssignment({
    required this.name,
    required this.value,
    int? location,
  });
}

class Operand {
  final AddressingMode addressingMode;
  final OperandValue value;

  Operand({required this.addressingMode, required this.value});
}

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

enum MacroValueType {
  byte,
  word,
  dword,
}
