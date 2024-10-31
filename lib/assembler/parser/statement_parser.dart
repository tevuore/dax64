import 'package:dax64/assembler/addressing_modes.dart';
import 'package:dax64/assembler/assembler_config.dart';
import 'package:dax64/assembler/errors.dart';
import 'package:dax64/assembler/parser/label.dart';
import 'package:dax64/assembler/parser/types.dart';
import 'package:dax64/models/generated/index.dart';
import 'package:dax64/utils/string_extensions.dart';

import '../../models/asm_program.dart';
import '../../models/statement/operand.dart';
import '../assembly.dart';
import 'comment.dart';
import 'operand_parser.dart';

AsmProgramLine parseStatementLine(final int lineNumber,
    final String unmodifiedLine, final AssemblerConfig config) {
  // instruction line syntax
  // (label) opcode (operand) (comments)

  var state = unmodifiedLine.trim();
  Comment? comment;
  (state, comment) = tryParseTrailingComment(state);

  Label? label;
  (state, label) = tryParsePrecedingLabel(state);

  if (state.trim().isEmpty) {
    throw AssemblerError("No opcode detected on line: $unmodifiedLine");
  }

  // so it is instruction line, but what kind of?

  // we have already parsed and taken away possible
  //  * trailing comment
  //  * preceding label
  //
  // so there will 1-2, syntax: opcode (operand)

  final partsRaw = state.trim().split(" ");
  // if there are multiple spaces then we get extra parts
  final partsReal = partsRaw.where((p) => p.isNotBlank()).toList();
  final parts = partsReal.map((p) => p.trim()).toList();
  assert(parts.isNotEmpty);
  assert(parts.length < 3);

  final opcodeStr = parts[0];
  final operandStr = parts.length == 2 ? parts[1] : null;

  if (!config.isOpcode(opcodeStr)) {
    throw AssemblerError('Not known opcode on line: $unmodifiedLine');
  }

  Instruction instructionObj = config.getInstruction(opcodeStr);
  Opcode opcodeObj;
  AddressingMode addressingMode;
  OperandValue operandValue;

  if (operandStr != null) {
    // statement can be either fully resolved, or has refs that require
    // resolving later when referenced values are known
    final statement = buildAssemblyStatement(instructionObj, operandStr);

    return AsmProgramLine(
      line: SourceLine(lineNumber, unmodifiedLine),
      comment: comment,
      statement: statement,
    );
  }

  // no operands, is that ok for this instruction
  final implicitOpcode = instructionObj.getImplicitOpcode();

  if (implicitOpcode == null) {
    throw AssemblerError(
        'No implicit opcode found for instruction: ${instructionObj.instruction}');
  }

  opcodeObj = implicitOpcode;
  operandValue = EmptyOperandValue();
  addressingMode = AddressingMode.implied;

  return AsmProgramLine(
      line: SourceLine(lineNumber, unmodifiedLine),
      comment: comment,
      statement: ResolvedAssemblyInstruction(
        statementStr: state,
        instructionSpec: instructionObj,
        label: label,
        // TeroV consider moving label on top level
        opcode: opcodeObj,
        operand: ResolvedOperand(
            addressingMode: addressingMode, value: operandValue, rawValue: ''),
      ));
}

AssemblyStatement buildAssemblyStatement(
    Instruction instruction, String input) {
  final (addressingMode, operandValue) = parseOperands(input);

  if (operandValue.isRefValue()) {
    final opcode = instruction.getOpcode(addressingMode);
    if (opcode == null) {
      throw AssemblerError(
          'No opcode found for instruction ${instruction.instruction} for addressing mode $addressingMode');
    }

    final operand = ResolvedOperand(
        addressingMode: addressingMode, value: operandValue, rawValue: input);

    // special case for relative addressing mode
    // TeroV remember to handle this also in late resolved!
    if (instruction.hasRelativeJumpInstruction(instruction) &&
        addressingMode == AddressingMode.absolute) {
      // opcode json had multiple opcodes for relative addressing mode, one per used bit
      throw NotImplementedAssemblerError(
          'Relative addressing mode not implemented for instruction: ${instruction.instruction}');
    }

    return ResolvedAssemblyInstruction(
        statementStr: input,
        instructionSpec: instruction,
        opcode: opcode,
        operand: operand);
  }

  // now assuming we are dealing with operand value whose value is not known
  // at this point. This means we can't resolve opcode as operand value affects
  // by defining is it referring to zero page or not.

  final operand = LateOperand(
      addressingMode: addressingMode,
      refOperandValue: operandValue as RefOperandValue,
      rawValue: input);

  return LateAssemblyInstruction(
      statementStr: input, instructionSpec: instruction, operand: operand);
}
