import 'package:dax64/assembler/assembler_config.dart';
import 'package:dax64/assembler/errors.dart';
import 'package:dax64/assembler/parser/comment.dart';
import 'package:dax64/assembler/parser/label.dart';
import 'package:dax64/assembler/parser/parser_state.dart';
import 'package:dax64/assembler/parser/statement_parser.dart';
import 'package:dax64/models/asm_program.dart';

import '../assembly.dart';
import 'assignment.dart';
import 'data.dart';

/// Assembly code is parsed one line at a time

// TODO what about macro statements? They certainly include multiple lines. How to parse them?
//  * Could it be that will implement memorable parsers? I.e. if matched and certain flag is set then parser element is kept and next time feed into again?
//  * Then we probably should use some kind of factory pattern already, which bakes in Match, i.e. Match/NoMatch
//  * But thinking about macros, they can contain multiple lines, empty lines, comments, labels  BUT
//    they can't contain other macro definitions, so could we have a sub pipeline?

final List<TryParser> lineParserPipeline = [
  tryParseEmptyLine,
  tryParseCommentLine,
  tryParseLabelOnOwnLine,
  tryParseDataLine,
  tryParseMacroAssignment,
  tryParseStatement,
  noMatchingParser,
];

/// parser line if matching, null otherwise
typedef TryParser = AsmProgramLine? Function(
    ParsingState state, AssemblerConfig config);

/// at assembly level we would handle label blocks and macros
/// i.e. those that are build from multiple program lines
Assembly parseNext(final SourceLine line, final AssemblerConfig config) {
  // TBD at this point we use just that there is one program file per assembly

  // TODO does it make sense to have SourceLine and ParsingState with similar structure?
  final state = ParsingState(line);

  for (final parser in lineParserPipeline) {
    final programLine = parser(state, config);
    if (programLine != null) {
      if (programLine.statement.isResolved()) {
        // TBD uses now ref to map, not safe usage
        return ResolvedAssembly([programLine], programLine.statement.defs());
      }

      return LateAssembly([programLine], programLine.statement.defs(),
          programLine.statement.refs());
    }
  }

  throw InternalAssemblerError("No matching line parser found", line);
}

AsmProgramLine? tryParseEmptyLine(ParsingState state, _) {
  return state.trimmedLine.isEmpty
      ? AsmProgramLine.withoutStatement(line: state.line)
      : null;
}

AsmProgramLine? tryParseStatement(
    ParsingState state, final AssemblerConfig config) {
  return parseStatementLine(state.line.lineNumber, state.line.raw, config);
}

/// This processor should be last in the pipeline and its purpose is just to
/// raise error if no other parsers matched a line.
AsmProgramLine? noMatchingParser(ParsingState state, _) {
  throw InternalAssemblerError(
      'No matching line processor for line', state.line);
}
