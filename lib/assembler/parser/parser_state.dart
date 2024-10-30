import '../errors.dart';

class ParsingState {
  final SourceLine line;
  final String trimmedLine;

  ParsingState(this.line) : trimmedLine = line.raw.trim();
}
