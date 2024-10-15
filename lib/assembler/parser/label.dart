import 'package:dax64/assembler/errors.dart';
import 'package:dax64/assembler/parser/parser_state.dart';
import 'package:dax64/utils/string_extensions.dart';

import '../../models/asm_program.dart';
import '../../models/statement/label.dart';
import '../assembler_config.dart';
import 'comment.dart';

final labelRegex = RegExp(r'^[ \t]*([a-zA-Z_][a-zA-Z0-9_]*):$');

void validateLabel(String? label) {
  if (label == null) {
    return;
  }
  var regex = RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$');
  if (!regex.hasMatch(label)) {
    throw AssemblerError('Invalid label: $label');
  }
}

// TODO not sure why on own line you need ':' at the end, but on statement line not
// TODO label can be on its own line and then it refers to following instruction

AsmProgramLine? tryParseLabelOnOwnLine(
    ParsingState state, final AssemblerConfig config) {
  // there could be a trailing comment
  var (remainingLine, comment) = tryParseTrailingComment(state.line);

  if (!remainingLine.trim().endsWith(':')) return null;

  final label = remainingLine.trim().dropLastChar();
  validateLabel(label);

  return AsmProgramLine(
      lineNumber: state.lineNumber,
      originalLine: state.line,
      comment: comment,
      statement: LabelStatement(label: label));
}

(String remainingLine, Label? label) tryParsePrecedingLabel(String line) {
  final match = labelRegex.firstMatch(line);
  if (match != null) {
    final label = match.group(1)!.trim();
    final remainingLine = line.replaceFirst(label, '').trimLeft();
    return (remainingLine, label);
  }

  return (line, null);
}

typedef Label = String;
