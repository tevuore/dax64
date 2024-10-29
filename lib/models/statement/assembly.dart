import 'package:dax64/assembler/errors.dart';
import 'package:meta/meta.dart';

import '../../assembler/addressing_modes.dart';
import '../../assembler/assembly_context.dart';
import '../generated/opcodes.dart';
import 'macro.dart';
import 'operand.dart';

// TeroV
// class AssemblyStatement extends Statement {
//   int? memoryAddress; // TODO should be only in machine instructions
//
//   AssemblyStatement({this.memoryAddress, super.label})
//       : super(shouldAssemble: true);
//
//   List<int> assemble(AssemblyContext context) {
//
//   }
//
// }
//
// class AssemblyInstruction extends AssemblyStatement {
//   final Instruction instructionSpec;
//   final Opcode opcode;
//   final Operand operand;
//
//   AssemblyInstruction({
//     required this.instructionSpec, // TeroV rename this? non spec
//     required this.opcode,
//     required this.operand,
//     super.label,
//     int? location,
//   }) : super(
//           memoryAddress: location,
//         );
// }

// TeroV is this correct place for class
// TeroV better name for this
abstract class Assembly {
  final String rawLine;
  final int lineNumber;
  final Instruction instructionSpec;

  // TeroV should this be private
  final Operand operand;

  // TeroV what about just label and empty lines?

  Assembly(
      {required this.rawLine,
      required this.lineNumber,
      required this.instructionSpec,
      required this.operand});

  Assembled assemble(AssemblyContext ctx);
}

typedef BytesIndex = int;
typedef LabelAddress = int;

@immutable
class Assembled {
  final List<int> bytes;
  final Map<LabelName, LabelAddress> resolvedLabels;
  final Map<LabelName, List<BytesIndex>> delayedLabels;

  Assembled({
    required List<int> bytes,
    required Map<LabelName, int> resolvedLabels,
    required Map<LabelName, List<BytesIndex>> delayedLabels,
  })  : bytes = List.unmodifiable(bytes),
        resolvedLabels = Map.unmodifiable(resolvedLabels),
        delayedLabels = Map.unmodifiable(delayedLabels);
}

class ResolvedAssembly extends Assembly {
  final ResolvedOperand resolvedOperand;
  final Opcode opcode;

  // TeroV what about just label and empty lines?

  ResolvedAssembly(
      {required super.rawLine,
      required super.lineNumber,
      required super.instructionSpec,
      required this.opcode,
      required this.resolvedOperand})
      : super(operand: resolvedOperand);

  @override
  List<int> assemble(AssemblyContext ctx) {
    return AssemblyInstruction(
        instructionSpec: instructionSpec, opcode: opcode, operand: operand);
  }
}

class LateAssembly extends Assembly {
  final LateOperand lateOperand;

  // TeroV what about just label and empty lines?

  LateAssembly(
      {required super.rawLine,
      required super.lineNumber,
      required super.instructionSpec,
      required this.lateOperand})
      : super(operand: lateOperand);

  @override
  AssemblyInstruction resolve(AssemblyContext ctx) {
    // TODO TeroV resolve opcode and operand

    final Opcode opcode;
    final ResolvedOperand operand;

    return AssemblyInstruction(
        instructionSpec: instructionSpec, opcode: opcode, operand: operand);
  }
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

/// Operand getters may throw an error if Operand is not yet resolved.
abstract class Operand {
  final String rawValue;

  Operand({required this.rawValue});

  bool isResolved();

  Operand resolve(AssemblyContext context);

  OperandValue getValue();

  AddressingMode getAddressingMode();
}

class ResolvedOperand extends Operand {
  final AddressingMode addressingMode;

  // TeroV how to distinguish that maybe ref value
  final OperandValue value;

  ResolvedOperand(
      {required this.addressingMode,
      required this.value,
      required super.rawValue});

  @override
  bool isResolved() => true;

  @override
  Operand resolve(AssemblyContext _) => this;

  @override
  OperandValue getValue() => value;

  @override
  AddressingMode getAddressingMode() => addressingMode;
}

/// Late operand contains label or macro refs why it can't be yet resolved
/// to final values.
class LateOperand extends Operand {
  LateOperand({required super.rawValue});

  @override
  bool isResolved() => true;

  @override
  Operand resolve(AssemblyContext ctx) {
    if (isResolved()) return this;

    final ResolvedOperand operand;
    // TODO TeroV supply vars from ctx and get real operand
    // TODO TeroV based on opcode we should we some limit what are possible values?
    // => parsed operand affects to used opcode -> this resolve should not be invoked directly

    return operand;
  }

  @override
  OperandValue getValue() => throw InternalAssemblerError(
      'Value for late resolved operand is not yet known');

  @override
  AddressingMode getAddressingMode() => throw InternalAssemblerError(
      'Addressing mode for late resolved operand is not yet known');
}
