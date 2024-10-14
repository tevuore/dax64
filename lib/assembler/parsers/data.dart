import 'package:dax64/assembler/parsers/label.dart';
import 'package:dax64/assembler/parsers/parser_state.dart';

import '../../models/asm_program.dart';
import '../../models/statement/assembly.dart';
import '../../models/statement/macro.dart';
import 'comment.dart';

final dataStatementRegex =
    RegExp(r'^([a-zA-Z_][a-zA-Z0-9_]*)[ \t]*\.([a-zA-Z]+)[ ]+(.*)$');

AsmProgramLine? tryParseDataLine(ParsingState state, _) {
  // match to pattern
  // (label:) .datatype <value>(,<value>) (;comment)

  // there could be a trailing comment
  final (remainingLine, comment) = tryParseTrailingComment(state.trimmedLine);

  final (remainingLine2, label) = tryParsePrecedingLabel(remainingLine);

  // data pseudo code starts with '.' char
  if (!remainingLine2.startsWith('.')) null;

  final regex = RegExp(r'^[ \t]*\.([a-z]+)[ \t]+(.*)$');
  final match = regex.firstMatch(remainingLine2);
  if (match == null) return null;

  final dataTypeStr = match.group(1)!;
  var dataType = MacroValueType.values.byName(dataTypeStr);

  final valueList = match.group(2)!.trim();
  final values = valueList.split(',').map((e) => e.trim()).toList();

  return AsmProgramLine(
      lineNumber: state.lineNumber,
      originalLine: state.line,
      comment: comment,
      statement: AssemblyData(label: label, type: dataType, values: values));
}
