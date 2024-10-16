import 'package:dax64/assembler/parser/label.dart';
import 'package:dax64/assembler/parser/parser_state.dart';

import '../../models/asm_program.dart';
import '../../models/statement/assembly.dart';
import '../../models/statement/macro.dart';
import '../assembler_config.dart';
import 'comment.dart';

// match to pattern
//   (label:) .datatype <value>(,<value>) (;comment)
final dataRegex = RegExp(r'^[ \t]*\.([a-zA-Z0-9]+)[ ]+(.*)$');

AsmProgramLine? tryParseDataLine(ParsingState state, final AssemblerConfig _) {
  // there could be a trailing comment
  final (remainingLine, comment) = tryParseTrailingComment(state.trimmedLine);

  final (remainingLine2, label) = tryParsePrecedingLabel(remainingLine);

  // data pseudo code starts with '.' char
  if (!remainingLine2.startsWith('.')) null;

  final match = dataRegex.firstMatch(remainingLine2);
  if (match == null) return null;

  final dataTypeStr = match.group(1)!;
  var dataType = MacroValueType.values.byName(dataTypeStr.toLowerCase());

  final valueList = match.group(2)!.trim();
  final values = valueList.split(',').map((e) => e.trim()).toList();

  return AsmProgramLine(
      lineNumber: state.lineNumber,
      originalLine: state.line,
      comment: comment,
      statement: AssemblyData(label: label, type: dataType, values: values));
}
