import 'package:dax64/assembler/parser/parser_state.dart';
import 'package:dax64/models/statement/empty.dart';
import 'package:dax64/models/statement/statement.dart';

// TOOO how to implement as immutable?

class AsmProgram {
  final List<AsmBlock> blocks = [];
}

class AsmBlock {
  final List<AsmProgramLine> lines = [];
}

class AsmProgramLine {
  final int lineNumber;
  final String originalLine;
  final String? comment;
  final Statement statement;

  AsmProgramLine(
      {required this.lineNumber,
      required this.originalLine,
      required this.statement,
      this.comment});

  AsmProgramLine.withoutStatement(
      {required this.lineNumber, required this.originalLine, this.comment})
      : statement = EmptyStatement.empty();

  AsmProgramLine.withoutStatementFromState(ParsingState state, {this.comment})
      : lineNumber = state.lineNumber,
        originalLine = state.line,
        statement = EmptyStatement.empty();
}
