import 'package:dax64/models/statement/statement.dart';

import '../../assembler/addressing_modes.dart';
import '../generated/opcodes.dart';
import 'macro.dart';
import 'operand.dart';

class AssemblyStatement extends Statement {
  int? memoryAddress; // TODO should be only in machine instructions

  AssemblyStatement({this.memoryAddress, super.label})
      : super(shouldAssemble: true);
}

class AssemblyInstruction extends AssemblyStatement {
  final Instruction instructionSpec;
  final Opcode opcode;
  final Operand?
      operand; // TODO shouldn't every instruction have at least place for addressing mode?

  AssemblyInstruction({
    required this.instructionSpec, // TeroV rename this? non spec
    required this.opcode,
    this.operand,
    super.label,
    int? location,
  }) : super(
          memoryAddress: location,
        );
}

class AssemblyData extends AssemblyStatement {
  final MacroValueType type;
  List<String> values = [];

  AssemblyData(
      {required this.type, required this.values, super.label, int? location})
      : super(
          memoryAddress: location,
        );
}

class Operand {
  final AddressingMode addressingMode;
  final OperandValue value;

  Operand({required this.addressingMode, required this.value});
}
