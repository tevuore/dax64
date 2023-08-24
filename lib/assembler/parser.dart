import 'package:dax64/assembler/addressing_modes.dart';
import 'package:dax64/assembler/errors.dart';
import 'package:dax64/models/asm_program.dart';
import 'package:dax64/models/generated/index.dart';

class Parser {
  final Map<String, Instruction> opcodeMap = {};

  Parser({required Opcodes opcodes}) {
    for (var instruction in opcodes.instructions) {
      opcodeMap[instruction.instruction] = instruction;
    }
  }

  AsmProgram parse(String input) {
    final program = AsmProgram();

    // currently there is just single block, but in future there could be
    // several separate memory areas
    final block = AsmBlock();
    program.blocks.add(block);
    var lineNumber = 1;
    for (final line in input.split('\n')) {
      var programLine = parseLine(lineNumber, line);
      block.lines.add(programLine);
      lineNumber++;
    }

    return program;
  }

  AsmProgramLine parseLine(int lineNumber, String unmodifiedLine) {
    var line = unmodifiedLine.trim();

    // skip empty lines
    if (line.isEmpty) {
      return AsmProgramLine(
          lineNumber: lineNumber, originalLine: unmodifiedLine);
    }

    // comments only lines
    var regex = RegExp(r'^[ \t]*;(.*)$');
    var match = regex.firstMatch(line);
    if (match != null) {
      var comment = match.group(1);
      return AsmProgramLine(
          lineNumber: lineNumber,
          originalLine: unmodifiedLine,
          comment: comment!.trim());
    }

    // instruction line syntax
    // (label) opcode (operand) (comments)
    // TODO label can be on its own line and then it refers to following instruction

    // macro assembler statements
    // <name> = <value>
    // (label) .datatype <value>(,<value>)

    String? label;
    String? opcode;
    String? operand;
    String? comment;

    // take all after comment char (note that we require always ; for comments
    // and ; is reserved for comments only
    var indexOfSemiComma = line.indexOf(';');
    if (indexOfSemiComma > 0) {
      comment = line.substring(indexOfSemiComma + 1).trim();
      line = line.substring(0, indexOfSemiComma).trim();
    }

    // is it data declaration? With or without label
    // TODO improve regex to work properly with label+whitespace
    regex = RegExp(r'^([a-zA-Z_][a-zA-Z0-9_]*)[ \t]*\.([a-zA-Z]+)[ ]+(.*)$');
    var m = regex.firstMatch(line);
    if (m != null) {
      if (m.group(1) != null) {
        label = m.group(1);
      }
      var dataType = MacroValueType.values.byName(m.group(2)!.toLowerCase());

      var valueList = m.group(3);
      var values = valueList!.split(',').map((e) => e.trim()).toList();

      return AsmProgramLine(
          lineNumber: lineNumber,
          originalLine: unmodifiedLine,
          statement:
              AssemblyData(label: label, type: dataType, values: values));
    }

    // macro assignment statement?

    regex = RegExp(r'^([a-zA-Z_][a-zA-Z0-9_]+)[ \t]?=[ \t]?(.+)$');
    m = regex.firstMatch(line);
    if (m != null) {
      final valueName = m.group(1);
      final value = m.group(2);

      return AsmProgramLine(
          lineNumber: lineNumber,
          originalLine: unmodifiedLine,
          statement: MacroAssignment(name: valueName!, value: value!));
    }

    // so it is instruction line

    // there will 1-4 parts (see syntax shown previously)
    // either 1st or 2nd part is opcode or asm statement
    final parts = splitInstructionLine(line);
    assert(parts.length < 4);

    if (isOpcode(parts[0])) {
      if (parts.length > 2) {
        throw AssemblerError(
            'Failed to parse line as too many parts after opcode: $unmodifiedLine');
      }
      opcode = parts[0];
      operand = parts.length == 2 ? parts[1] : null;
      comment = parts.length == 3 ? parts[2] : comment;
    } else if (parts.length > 1 && isOpcode(parts[1])) {
      label = parts[0];
      opcode = parts[1];
      operand = parts.length == 3 ? parts[2] : null;
      comment = parts.length == 4 ? parts[3] : comment;
    } else {
      // [0] could be label, and there is no opcode
      if (parts.length > 1) {
        throw AssemblerError(
            'Failed to parse line as no opcode found and there is input after label: $unmodifiedLine');
      }
      label = parts[0];
    }

    // TODO there are other places where label is parsed, same validation everywhere!
    validateLabel(label);

    if (opcode == null) {
      return AsmProgramLine(
          lineNumber: lineNumber,
          originalLine: unmodifiedLine,
          statement: AssemblyStatement(label: label));
    }

    if (!opcodeMap.containsKey(opcode)) {
      throw AssemblerError('Unknown instruction: $opcode');
    }

    Instruction instructionObj = opcodeMap[opcode]!;
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

  void validateLabel(String? label) {
    if (label == null) {
      return;
    }
    var regex = RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$');
    if (!regex.hasMatch(label)) {
      throw AssemblerError('Invalid label: $label');
    }
  }

  bool isOpcode(String input) {
    return input.startsWith('.') || opcodeMap.containsKey(input.toUpperCase());
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
}
