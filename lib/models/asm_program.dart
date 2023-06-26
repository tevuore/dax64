import 'package:c64/assembler/addressing_modes.dart';
import 'package:c64/models/generated/index.dart';

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
  final Statement? statement;

  AsmProgramLine(
      {required this.lineNumber,
      required this.originalLine,
      this.statement,
      this.comment});
}

abstract class Statement {
  bool get shouldAssemble;
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
  final Operand? operand;

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

class MacroInstruction extends Statement {
  @override
  final shouldAssemble = false;

// TODO macro definition

  MacroInstruction({int? location});
}

class MacroAssignment extends Statement {
  final String name;
  final String value; // TODO how to support different value types

  @override
  final shouldAssemble = false;

  MacroAssignment({
    required this.name,
    required this.value,
    int? location,
  });
}

class Operand {
  final AddressingMode addressingMode;
  final String? value;

  Operand({required this.addressingMode, required this.value});
}

enum MacroValueType {
  byte,
  word,
  dword,
}
