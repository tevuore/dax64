import 'package:dax64/assembler/addressing_modes.dart';
import 'package:dax64/assembler/assembler_config.dart';
import 'package:dax64/assembler/errors.dart';
import 'package:dax64/assembler/parsers/label.dart';
import 'package:dax64/models/generated/index.dart';

import '../../models/asm_program.dart';

AsmProgramLine parseStatementLine(final int lineNumber,
    final String unmodifiedLine, final AssemblerConfig config) {
  // instruction line syntax
  // (label) opcode (operand) (comments)
  // TODO label can be on its own line and then it refers to following instruction

  // TODO use this?
  //var state = LineParsingState(unmodifiedLine, unmodifiedLine.trim());
  var state = unmodifiedLine.trim();

  String? comment;
  (comment, state) = parseTrailingComment(state);

  final dataStatement =
      parseDataDefinitionWithOptionalLabel(lineNumber, state, comment);
  if (dataStatement != null) return dataStatement;

  final macroAssignment = parseMacroAssignment(lineNumber, state, comment);
  if (macroAssignment != null) return macroAssignment;

  String? label;
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

  // TODO there are other places where label is parsed, same validation everywhere!
  validateLabel(label);

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

typedef Comment = String;
typedef LineParsingState = String;

(Comment?, LineParsingState) parseTrailingComment(
    final String lineParsingState) {
  // take away all after comment char. Note that we require always ; for
  // comments and ; is reserved for comments only
  final line = lineParsingState.trim();
  final indexOfSemiComma = line.indexOf(';');
  if (indexOfSemiComma > 0) {
    final comment = line.substring(indexOfSemiComma + 1).trim();
    final remainingLine = line.substring(0, indexOfSemiComma).trim();
    return (comment, remainingLine);
  }

  return (null, lineParsingState);
}

// TODO we could include linenumber to state
AsmProgramLine? parseDataDefinitionWithOptionalLabel(
  final int lineNumber,
  final String state,
  final Comment? comment,
) {
  // match to pattern
  // (label) .datatype <value>(,<value>)
  final regex =
      RegExp(r'^([a-zA-Z_][a-zA-Z0-9_]*)[ \t]*\.([a-zA-Z]+)[ ]+(.*)$');

  // TODO improve regex to work properly with label+whitespace.
  //      Create test, not sure what is problem...

  var m = regex.firstMatch(state);
  if (m == null) return null;

  String? label;
  if (m.group(1) != null) {
    label = m.group(1);
  }
  var dataType = MacroValueType.values.byName(m.group(2)!.toLowerCase());

  var valueList = m.group(3);
  var values = valueList!.split(',').map((e) => e.trim()).toList();

  return AsmProgramLine(
      lineNumber: lineNumber,
      originalLine: state,
      comment: comment,
      statement: AssemblyData(label: label, type: dataType, values: values));
}

AsmProgramLine? parseMacroAssignment(
  final int lineNumber,
  final String state,
  final Comment? comment,
) {
  // match to pattern
  //   my_const = 0xaf
  final regex = RegExp(r'^([a-zA-Z_][a-zA-Z0-9_]+)[ \t]?=[ \t]?(.+)$');
  final m = regex.firstMatch(state);
  if (m == null) return null;

  final valueName = m.group(1);
  final value = m.group(2);

  return AsmProgramLine(
      lineNumber: lineNumber,
      originalLine: state,
      comment: comment,
      statement: MacroAssignment(name: valueName!, value: value!));
}

// TODO
// class LineParsingState {
//   final String originalLine;
//   final String currentPart;
//
//   LineParsingState(this.originalLine, this.currentPart) {}
//
//   LineParsingState copy({required String newCurrentPart}) { return LineParsingState(originalLine, newCurrentPart); }
// }

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
