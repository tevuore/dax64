import 'dart:collection';

import 'package:dax64/assembler/assembler_config.dart';
import 'package:dax64/assembler/errors.dart';
import 'package:dax64/assembler/parser/line_parsers.dart';
import 'package:dax64/models/asm_program.dart';
import 'package:meta/meta.dart';

import '../models/generated/opcodes.dart';
import '../models/statement/macro.dart';
import '../models/statement/operand.dart';
import '../models/statement/statement.dart';
import 'addressing_modes.dart';
import 'assembly_context.dart';

abstract class AssemblyStatement extends Statement {
  AssemblyStatement({super.label, required super.statementStr});

  List<int> assemble(AssemblyContext context);

  @override
  bool get shouldAssemble => true;
}

/// instruction where all values are known
class ResolvedAssemblyInstruction extends AssemblyStatement {
  final Instruction instructionSpec;
  final Opcode opcode;
  final ResolvedOperand operand;

  ResolvedAssemblyInstruction({
    required super.statementStr,
    required this.instructionSpec, // TeroV rename this? non spec
    required this.opcode,
    required this.operand,
    super.label,
  });

  @override
  List<int> assemble(AssemblyContext context) {
    // TODO: implement assemble
    throw UnimplementedError();
  }

  @override
  bool isResolved() => true;

  @override
  Map<String, dynamic> defs() {
    // TODO handling label is duplicate code...
    final map = HashMap<String, dynamic>();
    if (hasLabel()) {
      // TeroV not sure if this works out?
      map[label] = this;
    }
    return map;
  }

  // TODO we could have empty unmodifiable map
  @override
  Map<String, dynamic> refs() => HashMap();
}

/// instruction that contains references which are not yet resolved
class LateAssemblyInstruction extends AssemblyStatement {
  final Instruction instructionSpec;
  final LateOperand operand;

  LateAssemblyInstruction({
    required super.statementStr,
    required this.instructionSpec,
    required this.operand,
    super.label,
  });

  @override
  List<int> assemble(AssemblyContext context) {
    // TODO: implement assemble
    throw UnimplementedError();
  }

  @override
  bool isResolved() => false;

  @override
  Map<String, dynamic> defs() {
    // TODO handling label is duplicate code...
    final map = HashMap<String, dynamic>();
    if (hasLabel()) {
      // TeroV not sure if this works out?
      map[label] = this;
    }
    return map;
  }

  // TODO we could have empty unmodifiable map
  @override
  Map<String, dynamic> refs() {
    final map = HashMap<String, dynamic>();
    if (operand.refOperandValue.isRefValue()) {
      // TeroV does this works, what use value has?
      map[operand.refOperandValue.getRawValue()] = operand;
    }
    return map;
  }
}

// TeroV better name for this
abstract class Assembly {
  final List<AsmProgramLine> programLines;
  final Map<String, dynamic> defs = HashMap();
  final Map<String, dynamic> refs = HashMap();

  Assembly(this.programLines, Map<String, dynamic> defs_,
      Map<String, dynamic> refs_) {
    if (programLines.isEmpty) {
      throw InternalAssemblerError(
          'Creating Assembly with zero lines not allowed');
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
  // TODO these are not needed?
  //final Map<String, dynamic> refs = HashMap();
  //final Map<String, dynamic> defs = HashMap();

  final assembly = parseNext(sourceLine, config);
  //defs.addAll(assembly.defs);
  //refs.addAll(assembly.refs); // TeroV convert to list, values have no meaning

  return assembly;
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
  ResolvedAssembly(List<AsmProgramLine> programLines, Map<String, dynamic> defs)
      : super(programLines, defs, HashMap());

  @override
  Assembled assemble(AssemblyContext ctx) {
    // even though there is no refs to resolve, our piece of code may
    // have a label that gets now a known address => we need to pass that
    // info upwards

    return Assembled(
        bytes: bytes, resolvedLabels: resolvedLabels, delayedLabels: HashMap());
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
  // TeroV what about just label and empty lines?

  LateAssembly(super.programLines, super.defs, super.refs);

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
      {required this.type,
      required this.values,
      super.label,
      required super.statementStr});

  @override
  List<int> assemble(AssemblyContext context) {
    // TODO: implement assemble
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> defs() {
    final map = HashMap<String, dynamic>();
    if (hasLabel()) {
      // TeroV not sure if this works out?
      map[label] = this;
    }
    return map;
  }

  @override
  bool isResolved() {
    // TODO: implement isResolved
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> refs() {
    // TBD in principle data statements could refer to vars
    return HashMap();
  }
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
  final AddressingMode addressingMode;

  LateOperand(
      {required super.rawValue,
      required this.addressingMode,
      required this.refOperandValue});

  @override
  bool isResolved() => false;

  @override
  Operand resolve(AssemblyContext context) {
    throw NotImplementedAssemblerError("LateOperand not implemented");

    // TODO TeroV supply vars from ctx and get real operand
    // TODO TeroV based on opcode we should we some limit what are possible values?
    // => parsed operand affects to used opcode -> this resolve should not be invoked directly

    /// xxx
  }

  @override
  OperandValue getValue() => throw InternalAssemblerError(
      'Value for late resolved operand is not yet known');

  // TeroV do we need func instead of immutable member?
  @override
  AddressingMode getAddressingMode() => addressingMode;
}
