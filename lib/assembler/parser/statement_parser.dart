import 'package:dax64/assembler/addressing_modes.dart';
import 'package:dax64/assembler/assembler_config.dart';
import 'package:dax64/assembler/errors.dart';
import 'package:dax64/assembler/parser/label.dart';
import 'package:dax64/assembler/parser/types.dart';
import 'package:dax64/models/generated/index.dart';

import '../../models/asm_program.dart';
import '../../models/statement/assembly.dart';
import '../../models/statement/empty.dart';
import '../../models/statement/label.dart';
import '../../models/statement/operand.dart';
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

  String? opcode;
  String? operand;

  // so it is instruction line, but what kind of?

  // there will 1-4 parts (syntax: (label) opcode (operand) (comments))
  // either 1st or 2nd part is opcode or asm statement. Unfortunately there
  // is no character that clearly separates label and opcode.

  final parts = splitInstructionLine(state);
  assert(parts.length <
      4); // TeroV is this really true? If all syntax parts exists => create a test case

  // no label and first part is opcode
  if (config.isOpcode(parts[0])) {
    if (parts.length > 2) {
      // TeroV might here is same thing?
      throw AssemblerError(
          'Failed to parse line as too many parts after opcode: $unmodifiedLine');
    }
    opcode = parts[0];
    operand = parts.length == 2 ? parts[1] : null;
    comment = parts.length == 3 ? parts[2] : comment;

    // first part is label and second part is opcode
  } else if (parts.length > 1 && config.isOpcode(parts[1])) {
    label = parts[0];
    opcode = parts[1];
    operand = parts.length == 3 ? parts[2] : null;
    comment = parts.length == 4 ? parts[3] : comment;

    // only label
  } else {
    // [0] could be label, and there is no opcode
    if (parts.length > 1) {
      throw AssemblerError(
          'Failed to parse line as no opcode found and there is input after label: $unmodifiedLine');
    }
    label = parts[0]; // TeroV verify what is created based on this
  }

  if (opcode == null) {
    return AsmProgramLine(
        lineNumber: lineNumber,
        originalLine: unmodifiedLine,
        statement: label != null
            ? LabelStatement(label: label)
            : EmptyStatement.empty());
  }

  Instruction instructionObj = config.getInstruction(opcode);
  Opcode opcodeObj;
  AddressingMode addressingMode;
  OperandValue operandValue;

  if (operand != null) {
    final (parsedOpcodeObj, parsedOperandValue, parsedAddressingMode) =
        extractOperands(instructionObj, operand);
    opcodeObj = parsedOpcodeObj;
    operandValue = parsedOperandValue;
    addressingMode = parsedAddressingMode;
  } else {
    // no operands
    final opcodeObjs = instructionObj.opcodes
        .where((element) => element.bytes.length == 1)
        .toList();
    if (opcodeObjs.isEmpty) {
      throw AssemblerError(
          'No unique implicit opcode found for instruction: ${instructionObj.instruction}');
    }
    opcodeObj = opcodeObjs[0];
    operandValue = EmptyOperandValue();
    addressingMode = AddressingMode.implied;
  }

  return AsmProgramLine(
      lineNumber: lineNumber,
      originalLine: unmodifiedLine,
      comment: comment,
      statement: AssemblyInstruction(
        instructionSpec: instructionObj,
        label: label,
        opcode: opcodeObj,
        operand: Operand(addressingMode: addressingMode, value: operandValue),
      ));
}

List<String> splitInstructionLine(String input) {
  input = input.trim();
  if (input.isEmpty) {
    return [];
  }

  // TODO by quick look I don't follow why so many if statements?

  final parts = <String>[];

  var indexOfSpace = input.indexOf(' ');
  if (indexOfSpace > -1) {
    parts.add(input.substring(0, indexOfSpace).trim());
    input = input.substring(indexOfSpace).trim();
  } else {
    parts.add(input);
    return parts;
  }

  indexOfSpace = input.indexOf(' ');
  if (indexOfSpace > -1) {
    parts.add(input.substring(0, indexOfSpace).trim());
    input = input.substring(indexOfSpace).trim();
  } else {
    parts.add(input);
    return parts;
  }

  indexOfSpace = input.indexOf(' ');
  if (indexOfSpace > -1) {
    parts.add(input.substring(0, indexOfSpace).trim());
    // final part is comment
  } else {
    parts.add(input);
  }

  return parts;
}

(Opcode, OperandValue, AddressingMode) extractOperands(
    Instruction instruction, String input) {
  final (addressingMode, operandValue) = parseOperands(input);

  // special case for relative addressing mode
  if (isRelativeJumpInstruction(instruction) &&
      addressingMode == AddressingMode.absolute) {
    // opcode json had multiple opcodes for relative addressing mode, one per used bit
    throw NotImplementedAssemblerError(
        'Relative addressing mode not implemented for instruction: ${instruction.instruction}');
  }

  return (
    instruction.opcodes.firstWhere((element) =>
        areSameAddressingModes(element.addressMode, addressingMode)),
    operandValue,
    addressingMode,
  );
}

bool isRelativeJumpInstruction(Instruction instruction) {
  return instruction.opcodes
      .every((element) => element.addressMode.endsWith("Rela"));
}
