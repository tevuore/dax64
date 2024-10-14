import 'package:dax64/assembler/parser/parser_state.dart';
import 'package:dax64/assembler/parser/types.dart';

import '../../models/asm_program.dart';
import '../errors.dart';

AsmProgramLine? tryParseCommentLine(ParsingState state, _) {
  // comments only lines
  if (!state.trimmedLine.startsWith(';')) return null;

  final regex = RegExp(r'^[ \t]*;(.*)$');
  final match = regex.firstMatch(state.line);
  if (match != null) {
    final comment = match.group(1);
    return AsmProgramLine.withoutStatementFromState(state,
        comment: comment!.trim());
  }

  throw AssemblerError(
    'Failed to parse comment from line: ${state.lineNumber}: ${state.line}',
  );
}

(String remainingLine, Comment? comment) tryParseTrailingComment(String line) {
  int commentStartIndex = line.indexOf(';');
  if (commentStartIndex < 0) return (line, null);

  // we treat all chars after ';' as a comment
  Comment comment = line.substring(commentStartIndex + 1, line.length);
  String remainingLine = line.substring(0, commentStartIndex);

  return (remainingLine, comment);
}
