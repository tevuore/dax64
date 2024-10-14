import 'package:dax64/assembler/assembler_config.dart';
import 'package:dax64/assembler/errors.dart';
import 'package:dax64/assembler/parser/comment.dart';
import 'package:dax64/assembler/parser/label.dart';
import 'package:dax64/assembler/parser/parser_state.dart';
import 'package:dax64/assembler/parser/statement_parser.dart';
import 'package:dax64/models/asm_program.dart';

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
  tryParseStatement,
  noMatchingParser,
];

/// parser line if matching, null otherwise
typedef TryParser = AsmProgramLine? Function(
    ParsingState state, AssemblerConfig config);

// TODO a single parser could try to iterate to next line too... well then return type would be a list

AsmProgramLine parseAsmProgramLine(
    final lineNumber, final String line, final AssemblerConfig config) {
  final state = ParsingState(lineNumber, line);

  for (final parser in lineParserPipeline) {
    final programLine = parser(state, config);
    if (programLine != null) {
      return programLine;
    }
  }

  throw InternalAssemblerError("No matching line parser found");
}

AsmProgramLine? tryParseEmptyLine(ParsingState state, _) {
  return state.trimmedLine.isEmpty
      ? AsmProgramLine.withoutStatementFromState(state)
      : null;
}

AsmProgramLine? tryParseStatement(
    ParsingState state, final AssemblerConfig config) {
  return parseStatementLine(state.lineNumber, state.line, config);
}

/// This processor should be last in the pipeline and its purpose is just to
/// raise error if no other parsers matched a line.
AsmProgramLine? noMatchingParser(ParsingState state, _) {
  throw InternalAssemblerError(
      'No matching line processor for line: ${state.lineNumber}: ${state.line}');
}
