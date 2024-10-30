import 'dart:collection';

import 'package:dax64/assembler/assembler_config.dart';
import 'package:dax64/assembler/errors.dart';
import 'package:dax64/assembler/parser/line_parsers.dart';
import 'package:dax64/models/asm_program.dart';
import 'package:meta/meta.dart';

import '../models/statement/statement.dart';
import 'addressing_modes.dart';
import 'assembly_context.dart';
import '../models/generated/opcodes.dart';
import '../models/statement/macro.dart';
import '../models/statement/operand.dart';


class AssemblyStatement extends Statement {

  AssemblyStatement({super.label})
      : super(shouldAssemble: true);

  List<int> assemble(AssemblyContext context) {

  }

}

class AssemblyInstruction extends AssemblyStatement {
  final Instruction instructionSpec;
  final Opcode opcode;
  final Operand operand;

  AssemblyInstruction({
    required this.instructionSpec, // TeroV rename this? non spec
    required this.opcode,
    required this.operand,
    super.label,
  }) : super(
          memoryAddress: location,
        );
}

// TeroV better name for this
abstract class Assembly {
  final List<AsmProgramLine> programLines;
  final Map<String, dynamic> defs = HashMap();
  final Map<String, dynamic> refs = HashMap();

  Assembly(this.programLines, Map<String, dynamic> defs_, Map<String, dynamic> refs_) {
    if (programLines.isEmpty) {
      throw InternalAssemblerError('Creating Assembly with zero lines not allowed');
    }
    defs.addAll(defs_);
    refs.addAll(refs_);
  }

  int getStartingLine() => programLines[0].line.lineNumber;
  int getLineCount() => programLines.length;

  Assembled assemble(AssemblyContext ctx);
}

// TODO impl parsing multiple lines, like for macro or label block
Assembly parseAssembly(SourceLine sourceLine, AssemblerConfig config) {
  final Map<String, dynamic> refs = HashMap();
  final Map<String, dynamic> defs = HashMap();

  final programLine = parseNext(sourceLine, config);

  // TODO not sure why label can't be null (or Option)
  if (programLine.statement.hasLabel()) {
    final label = programLine.statement.label;
    if (defs.containsKey(label)) {
      throw AssemblerError("Label '$label' defined here twice", sourceLine);
    }
    defs[programLine.statement.label] = programLine;

    if (programLine.statement is MacroAssignment) {
      final assignment = programLine.statement as MacroAssignment;

      if (defs.containsKey(assignment.name)) {
        throw AssemblerError('Variable ${assignment.name} defined twice', sourceLine);
      }
      defs[assignment.name] = assignment;
    } else if (programLine.statement is MacroDefinition) {
      final macro = programLine.statement as MacroDefinition;
      if (defs.containsKey(macro.name)) {
        throw AssemblerError('Macro ${macro.name} defined twice', sourceLine);
      }
      defs[macro.name] = macro;
    }
  }

  if (programLine.isResolved()) {
    return ResolvedAssembly([programLine], defs);
  }
  xxx impl isResolved() in statement level
  xxx for which we need late assembly, if statement already parses
  // TeroV we handle just labels on own lines?
  return LateAssembly(rawLine: rawLine, lineNumber: lineNumber, instructionSpec: instructionSpec, lateOperand: lateOperand)
}

typedef BytesIndex = int;
typedef LabelAddress = int;

/// return value from assembling Assembly
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

/// Resolved assembly means that there are no label refs, variables, or macros
/// to resolve.
class ResolvedAssembly extends Assembly {

  ResolvedAssembly(
      List<AsmProgramLine> programLines,
      Map<String, dynamic> defs)
      : super(programLines, defs, HashMap());

  @override
  Assembled assemble(AssemblyContext ctx) {
    // even though there is no refs to resolve, our piece of code may
    // have a label that gets now a known address => we need to pass that
    // info upwards

    return Assembled(
      bytes: bytes,
      resolvedLabels: resolvedLabels,
      delayedLabels: HashMap()
    );
  }
}

/// Late assembly means code that contains references to labels, macros or
/// variables that are not yet known.
///
/// Note that even after assembling LateAssembly an exact address referred
/// by a label maybe unknown, so called delayed label. But higher levels
/// of assembling logic take care of that.
///
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
  Assembled assemble(AssemblyContext ctx) {
    // even though there is no refs to resolve, our piece of code may
    // have a label that gets now a known address.

    return Assembled(
        bytes: bytes,
        resolvedLabels: resolvedLabels,
        delayedLabels: delayedLabels,
    );
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
  final OperandValue value;

  ResolvedOperand(
      {required this.addressingMode,
      required this.value,
      required super.rawValue});

  @override
  bool isResolved() => true;

  @override
  Operand resolve(AssemblyContext context) => this;

  @override
  OperandValue getValue() => value;

  @override
  AddressingMode getAddressingMode() => addressingMode;
}

/// Late operand contains label or macro refs why it can't be yet resolved
/// to final values.
///
class LateOperand extends Operand {
  final RefOperandValue refOperandValue;
  LateOperand({required super.rawValue, required this.refOperandValue});

  @override
  bool isResolved() => false;

  @override
  Operand resolve(AssemblyContext context) {

    refOperandValue.
    final ResolvedOperand operand;
    // TODO TeroV supply vars from ctx and get real operand
    // TODO TeroV based on opcode we should we some limit what are possible values?
    // => parsed operand affects to used opcode -> this resolve should not be invoked directly

    xxx how parsing of operands worked earlier??

    return OperandValue(

    );
  }

  @override
  OperandValue getValue() => throw InternalAssemblerError(
      'Value for late resolved operand is not yet known');

  @override
  AddressingMode getAddressingMode() => throw InternalAssemblerError(
      'Addressing mode for late resolved operand is not yet known');
}
