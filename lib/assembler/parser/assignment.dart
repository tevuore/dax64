import 'package:dax64/assembler/parser/parser_state.dart';

import '../../models/asm_program.dart';
import '../../models/statement/macro.dart';
import '../assembler_config.dart';
import 'comment.dart';
import 'label.dart';

// match to pattern
//   my_const = 0xaf
final assignmentRegex = RegExp(r'^([a-zA-Z_][a-zA-Z0-9_]+)[ \t]?=[ \t]?(.+)$');

AsmProgramLine? tryParseMacroAssignment(
    ParsingState state, final AssemblerConfig _) {
  final (remainingLine, comment) = tryParseTrailingComment(state.trimmedLine);
  final (remainingLine2, label) = tryParsePrecedingLabel(remainingLine);

  final m = assignmentRegex.firstMatch(remainingLine2);
  if (m == null) return null;

  final valueName = m.group(1);
  final value = m.group(2)!.trim();

  return AsmProgramLine(
      lineNumber: state.lineNumber,
      originalLine: state.line,
      comment: comment,
      statement: MacroAssignment(name: valueName!, value: value!));
}
