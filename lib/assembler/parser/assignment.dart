import 'package:dax64/assembler/parser/types.dart';

import '../../models/asm_program.dart';
import '../../models/statement/macro.dart';

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
