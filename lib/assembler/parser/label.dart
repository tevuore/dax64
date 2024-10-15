import 'package:dax64/assembler/errors.dart';
import 'package:dax64/assembler/parser/parser_state.dart';
import 'package:dax64/utils/string_extensions.dart';

import '../../models/asm_program.dart';
import '../../models/statement/label.dart';
import '../assembler_config.dart';
import 'comment.dart';

final labelRegex = RegExp(r'^[ \t]*([a-zA-Z_][a-zA-Z0-9_]*:).*$');

void validateLabel(String? label) {
  if (label == null) {
    return;
  }
  if (!labelRegex.hasMatch(label.trim())) {
    throw AssemblerError('Invalid label: $label');
  }
}

AsmProgramLine? tryParseLabelOnOwnLine(
    ParsingState state, final AssemblerConfig config) {
  // there could be a trailing comment
  var (remainingLine, comment) = tryParseTrailingComment(state.line);

  if (!remainingLine.trim().endsWith(':')) return null;

  final label = remainingLine.trim();
  validateLabel(label);

  return AsmProgramLine(
      lineNumber: state.lineNumber,
      originalLine: state.line,
      comment: comment,
      statement: LabelStatement(label: label.dropLastChar()));
}

(String remainingLine, Label? label) tryParsePrecedingLabel(String line) {
  final match = labelRegex.firstMatch(line.trim());
  if (match != null) {
    final label = match.group(1)!.trim();
    final remainingLine = line.replaceFirst(label, '').trimLeft();
    return (remainingLine, label.dropLastChar());
  }

  return (line, null);
}

typedef Label = String;
