import 'package:c64/assembler/errors.dart';
import 'package:c64/models/generated/index.dart';

class ParserElement {
  final String? label;
  final String? instruction;
  final String? operand;
  final String? comment;

  ParserElement({this.label, this.instruction, this.operand, this.comment});
}

class Parser {
  final Map<String, Instruction> opcodeMap = {};

  Parser({required Opcodes opcodes}) {
    for (var instruction in opcodes.instructions) {
      opcodeMap[instruction.instruction] = instruction;
    }
  }

  List<ParserElement> parse(String input) {
    List<ParserElement> elements = [];

    final lines = input.split('\n');
    for (final line in lines) {
      var ele = parseLine(line);
      if (ele != null) elements.add(ele);
    }

    return elements;
  }

  ParserElement? parseLine(String unmodifiedLine) {
    var line = unmodifiedLine.trim();

    // skip empty lines
    if (line.isEmpty) {
      return null;
    }

    // skip comments only lines
    var regex = RegExp(r'^[ \t]*;(.*)$');
    var match = regex.firstMatch(line);
    if (match != null) {
      var comment = match.group(1);
      return comment != null ? ParserElement(comment: comment.trim()) : null;
    }

    // instruction line syntax
    // (label) opcode (operand) (comments)

    String? label;
    String? opcode;
    String? operand;
    String? comment;

    // take all after comment char (note that comments may appear without
    // ';' char, they are just last field on instruction line)
    var indexOfSemiComma = line.indexOf(';');
    if (indexOfSemiComma > 0) {
      comment = line.substring(indexOfSemiComma + 1).trim();
      line = line.substring(0, indexOfSemiComma).trim();
    }

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

    validateLabel(label);

    return ParserElement(
        label: label, instruction: opcode, operand: operand, comment: comment);
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
    return opcodeMap.containsKey(input.toUpperCase());
  }
}
