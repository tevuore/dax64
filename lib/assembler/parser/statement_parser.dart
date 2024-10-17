import 'package:dax64/assembler/addressing_modes.dart';
import 'package:dax64/assembler/assembler_config.dart';
import 'package:dax64/assembler/errors.dart';
import 'package:dax64/assembler/parser/label.dart';
import 'package:dax64/assembler/parser/types.dart';
import 'package:dax64/models/generated/index.dart';
import 'package:dax64/utils/string_extensions.dart';

import '../../models/asm_program.dart';
import '../../models/statement/assembly.dart';
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

  if (state.trim().isEmpty)
    throw AssemblerError("No opcode detected on line: $unmodifiedLine");

  String? opcode;
  String? operand;

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
    (opcodeObj, operandValue, addressingMode) =
        extractOperandParts(instructionObj, operandStr);
  } else {
    // no operands, is that ok for instruction
    xxx put this method elsewhere
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
        label: label, // TeroV consider moving label on top level
        opcode: opcodeObj,
        operand: Operand(addressingMode: addressingMode, value: operandValue),
      ));
}

(Opcode, OperandValue, AddressingMode) extractOperandParts(
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
