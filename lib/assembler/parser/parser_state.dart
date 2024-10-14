class ParsingState {
  final int lineNumber;
  final String line;
  final String trimmedLine;

  ParsingState(this.lineNumber, this.line) : trimmedLine = line.trim();
}
