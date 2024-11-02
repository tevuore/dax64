import 'dart:collection';

import 'package:dax64/assembler/assembler_config.dart';
import 'package:dax64/assembler/errors.dart';
import 'package:dax64/assembler/parser/line_parsers.dart';
import 'package:dax64/assembler/parser/operand_parser.dart';
import 'package:dax64/models/asm_program.dart';
import 'package:dax64/models/statement/empty.dart';
import 'package:meta/meta.dart';

import '../models/generated/opcodes.dart';
import '../models/statement/label.dart';
import '../models/statement/macro.dart';
import '../models/statement/operand.dart';
import '../models/statement/statement.dart';
import '../utils/hex8bit.dart';
import 'addressing_modes.dart';
import 'assembly_context.dart';

typedef Bytes = List<int>;
typedef ResolvedLabels = Map<LabelName, Label>;
// TODO delayedlabels 'int' has different meaning on different levels, it is either memory address or byte index => we should have real type to distuingih
typedef DelayedLabels = Map<LabelName, List<int>>;

abstract class AssemblyStatement extends Statement {
  AssemblyStatement({super.label, required super.statementStr});

  // TeroV is needed on this level?
  //List<int> assemble(AssemblyContext context);

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

  (List<int>, DelayedLabels) assemble(AssemblyContext context) {
    final Bytes bytes = [];
    final DelayedLabels delayedLabels = HashMap();

    final resolvedOperand = operand.resolve(context);
    if (resolvedOperand.isResolved()) {
      // all good => all bytes can be resolved
      final opcode =
          instructionSpec.getOpcode(resolvedOperand.getAddressingMode());
      if (opcode == null) {
        throw AssemblerError(
            'Addressing mode is not used by instruction: original=$statementStr, resolved operand=${resolvedOperand.rawValue}, addressing mode=${resolvedOperand.getAddressingMode()}');
      }
      bytes.add(parse8BitHex(opcode.opcode));
      bytes
          .addAll(resolvedOperand.getValue().toBytes().toList(growable: false));

      return (bytes, DelayedLabels());
    } else {
      // a label ref that is unknown
      // TODO assuming ref must two be bytes

      // when we initially tried to parse operand we couldn't say if absolute
      // or zero page addressing mode is used, now based on that original
      // hint we can know final addressing mode
      final addressingMode = resolveAddressingModeFromHint();
      // just in case check addressing mode is support
      final opcode = instructionSpec.getOpcode(addressingMode);
      if (opcode == null) {
        throw AssemblerError(
            "Instruction ${instructionSpec.instruction} doesn't support addressing mode: $addressingMode");
      }

      bytes.add(parse8BitHex(opcode.opcode));
      bytes.addAll([-1, -1]); // TeroV does validation allow -1 as marker?

      // TODO in which case we could have multiple values?
      delayedLabels[operand.refOperandValue.getRawValue()] = [1];

      return (bytes, DelayedLabels());
    }
  }

  AddressingMode resolveAddressingModeFromHint() {
    // TODO at this point we know referred value is two byte label, i.e. no zero page addressing

    // in principle we wouldn't need to check all, as not all addressing modes should
    // end up this handling, like ones without operand. But it is easier to figure out
    // problems if all are listed here
    switch (operand.addressingModeHint) {
      case AddressingMode.absolute:
      case AddressingMode.absoluteX:
      case AddressingMode.absoluteY:
      case AddressingMode.accumulator:
      case AddressingMode.immediate:
      case AddressingMode.implied:
      case AddressingMode.indirect:
      case AddressingMode.indirectX:
      case AddressingMode.indirectY:
      case AddressingMode.relative:
        return operand.addressingModeHint;

      case AddressingMode.zeropage:
        return AddressingMode.absolute;
      case AddressingMode.zeropageX:
        return AddressingMode.absoluteX;
      case AddressingMode.zeropageY:
        return AddressingMode.absoluteY;

      default:
        throw InternalAssemblerError(
            'Unsupported addressing mode: ${operand.addressingModeHint}');
    }
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

  Assembled assemble(AssemblyContext context);
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
  Assembled assemble(AssemblyContext context) {
    // even though there is no refs to resolve, our piece of code may
    // have a label that gets now a known address => we need to pass that
    // info upwards

    final bytes = <int>[];
    final Map<LabelName, int> resolvedLabels = HashMap();
    var currentContext = context;

    for (final programLine in programLines) {
      if (programLine.statement.shouldAssemble) {
        try {
          switch (programLine.statement) {
            case AssemblyStatement statement:
              final (statementBytes, statementResolvedLabels) =
                  assembleAssemblyStatement(statement, currentContext);
              bytes.addAll(statementBytes);
              for (final label in statementResolvedLabels.values) {
                if (label.memoryAddress == null) {
                  throw InternalAssemblerError('Label has no memory address');
                }
                if (resolvedLabels.containsKey(label.name)) {
                  throw AssemblerError('Label resolved twice: ${label.name}');
                }

                // TODO should we use Label as value instead of just int
                resolvedLabels[label.name] = label.memoryAddress!;
              }

              final int currentMemoryAddress = context.currentMemoryAddress;
              currentContext = currentContext.updateCopy(
                  currentMemoryAddress_: currentMemoryAddress,
                  resolvedLabels: resolvedLabels);
              break;

            case final MacroStatement _:
              throw UnimplementedError('Macro statements not yet implemented');

            default:
              throw InternalAssemblerError(
                  "Encountered statement that should be assembled but doesn't have assembler logic: ${programLine.line}");
          }
        } catch (e, stacktrace) {
          // TODO with verbose flag print stacktrace
          print(e);
          print(stacktrace);

          throw AssemblerError('Assembling error: $e', programLine.line);
        }
      }
    }

    return Assembled(
        bytes: bytes, resolvedLabels: resolvedLabels, delayedLabels: HashMap());
  }

  ///
  (Bytes, ResolvedLabels) assembleAssemblyStatement(
      AssemblyStatement assemblyStatement, AssemblyContext context) {
    final Bytes bytes = [];
    final ResolvedLabels resolvedLabels = HashMap();

    switch (assemblyStatement) {
      case ResolvedAssemblyInstruction instruction:
        // special case for relative addressing mode
        if (_isRelativeJumpInstruction(instruction.instructionSpec) &&
            instruction.operand.getAddressingMode() ==
                AddressingMode.absolute) {
          throw NotImplementedAssemblerError(
              'Relative addressing mode not implemented for instruction: ${instruction.instructionSpec}');
        }

        // TeroV this exact assembling can be moved To ResolvedInstruction.assemble()
        //final (bytes, delayedLabels) = instruction.assemble(context);

        bytes.add(parse8BitHex(instruction.opcode.opcode)); // TODO opcode 2x?

        // operand may refer to macro or label, so to resolve those
        final operand = instruction.operand.resolve(context);
        // TeroV to where following is needed?
        // var expectedAddressingMode = opcode.map((opcode) => addressingModes[opcode.addressMode]).toList();
        final operandBytes = parseOperandValue(operand);
        bytes.addAll(operandBytes.toList());

        if (assemblyStatement.hasLabel()) {
          // as we are handling single statement it means possible labels points
          // to first byte, i.e. memory location pointed by context
          resolvedLabels[assemblyStatement.label] = Label(
              name: assemblyStatement.label,
              memoryAddress: context.currentMemoryAddress);
        }
        break;

      case AssemblyData data:
        // TeroV impl
        throw NotImplementedAssemblerError(
            "AssemblyData assembling not yet implemented");

      case LabelStatement label:
        // there is just label, no instructions
        resolvedLabels[label.label] = Label(
            name: assemblyStatement.label,
            memoryAddress: context.currentMemoryAddress);
        break;

      case EmptyStatement _:
        // just skip
        break;

      default:
        throw InternalAssemblerError(
            "Unsupported AssemblyStatement encountered during assembling resolved entities");
    }

    return (bytes, resolvedLabels);
  }
}

// TODO what is right location
// TODO when this is implemented? What is difficulty?
bool _isRelativeJumpInstruction(Instruction instruction) {
  return instruction.opcodes
      .every((element) => element.addressMode.endsWith("Rela"));
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
  Assembled assemble(AssemblyContext context) {
    // LateAssembly should contain at least one ref to be resolved
    //  - all variables and macros should get resolved
    //  - a label may get resolved if ref it is known (memory address)
    //  - if label is not known then it is called 'delayed'
    //    => we indicate location in assembled bytes where label can be
    //       later placed
    //
    //  Note that a as assembly may contain multiple lines so in there
    //  could be both resolved labels and delayed labels.
    //  It is in fact possible that generated assembly contains ref
    //  to label inside there program lines.

    final bytes = <int>[];
    final Map<LabelName, int> currentResolvedLabels = HashMap();
    currentResolvedLabels.addAll(context.labels().map((name, obj) =>
        MapEntry(name, obj.memoryAddress!))); // TBD better error checking?
    final Map<LabelName, int> newResolvedLabels = HashMap();
    final Map<LabelName, List<BytesIndex>> delayedLabels = HashMap();
    var currentContext = context;

    for (final programLine in programLines) {
      if (programLine.statement.shouldAssemble) {
        try {
          switch (programLine.statement) {
            case AssemblyStatement statement:
              final (
                statementBytes,
                statementResolvedLabels,
                statementDelayedLabels
              ) = _assembleAssemblyStatement(statement, currentContext);
              bytes.addAll(statementBytes);
              if (statementDelayedLabels.isNotEmpty) {
                delayedLabels.addAll(statementDelayedLabels);
              }

              for (final label in statementResolvedLabels.values) {
                if (label.memoryAddress == null) {
                  throw InternalAssemblerError('Label has no memory address');
                }
                if (currentResolvedLabels.containsKey(label.name)) {
                  throw AssemblerError('Label resolved twice: ${label.name}');
                }

                // TODO should we use Label as value instead of just int
                // TeroV this similar setup should be impl on Resolved side
                currentResolvedLabels[label.name] = label.memoryAddress!;
                newResolvedLabels[label.name] = label.memoryAddress!;
              }

              final int currentMemoryAddress = context.currentMemoryAddress;
              currentContext = currentContext.updateCopy(
                  currentMemoryAddress_: currentMemoryAddress,
                  resolvedLabels:
                      newResolvedLabels); // TeroV this unnecessarily add also entries on previous round
              break;

            case final MacroStatement _:
              throw UnimplementedError('Macro statements not yet implemented');

            default:
              throw InternalAssemblerError(
                  "Encountered statement that should be assembled but doesn't have assembler logic: ${programLine.line}");
          }
        } catch (e, stacktrace) {
          // TODO with verbose flag print stacktrace
          print(e);
          print(stacktrace);

          throw AssemblerError('Assembling error: $e', programLine.line);
        }
      }
    }

    return Assembled(
        bytes: bytes,
        resolvedLabels: newResolvedLabels,
        delayedLabels: delayedLabels);
  }

  ///
  (Bytes, ResolvedLabels, DelayedLabels) _assembleAssemblyStatement(
      AssemblyStatement assemblyStatement, AssemblyContext context) {
    switch (assemblyStatement) {
      case LateAssemblyInstruction instruction:
        if (!instruction.isResolved()) {
          throw InternalAssemblerError(
              'Trying to resolve LateAssemblyInstruction that is already resolved');
        }
        // special case for relative addressing mode
        if (_isRelativeJumpInstruction(instruction.instructionSpec) &&
            instruction.operand.getAddressingMode() ==
                AddressingMode.absolute) {
          throw NotImplementedAssemblerError(
              'Relative addressing mode not implemented for instruction: ${instruction.instructionSpec}');
        }

        final (bytes, delayedLabels) = instruction.assemble(context);

        final ResolvedLabels resolvedLabels = HashMap();
        if (assemblyStatement.hasLabel()) {
          // as we are handling single statement it means possible labels points
          // to first byte, i.e. memory location pointed by context
          resolvedLabels[assemblyStatement.label] = Label(
              name: assemblyStatement.label,
              memoryAddress: context.currentMemoryAddress);
        }

        return (bytes, resolvedLabels, delayedLabels);

      default:
        throw InternalAssemblerError(
            "Unsupported AssemblyStatement encountered during assembling late entities");
    }
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

  // TeroV in all cases this can't be resolved before hand if there not yet known difference between absolute and zero page
  final AddressingMode addressingModeHint;

  LateOperand(
      {required super.rawValue,
      required this.addressingModeHint,
      required this.refOperandValue});

  @override
  bool isResolved() => false;

  // TeroV is there need to have this on upper level (override?)
  @override
  Operand resolve(AssemblyContext context) {
    // TODO at this first impl we assume that all zero page labels have been already
    //      resolved so their value is in context. So we can assume that all not yet
    //      resolved labels must lead to absolute addressing mode

    final resolvedValue = refOperandValue.resolve(context);
    if (!resolvedValue.isRefValue()) {
      // all known, good to go
      // TeroV there is double work as resolving value already returned created OperandValue object
      //       but without actual parsing we don't know addressing mode...
      final (addressingMode, operandValue) = parseOperands(resolvedValue
          .getIntValue()
          .toString()); // TeroV does it work or should it be toHexValue()?

      // TBD information from where this was resolved it lost, could be needed for good error messages...
      return ResolvedOperand(
          addressingMode: addressingMode,
          value: operandValue,
          rawValue: resolvedValue.getRawValue());
    }

    // this must be case when label is referred and not known
    return this;
  }

  @override
  OperandValue getValue() => throw InternalAssemblerError(
      'Value for late resolved operand is not yet known');

  // TeroV do we need func instead of immutable member?
  @override
  AddressingMode getAddressingMode() =>
      throw InternalAssemblerError("LateOperand doesn't know addressing mode");
}
