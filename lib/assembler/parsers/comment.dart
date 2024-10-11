// TODO add test for this case

(String remainingLine, String? comment) tryParseTrailingComment(String line) {
  int commentStartIndex = line.indexOf(';');
  if (commentStartIndex < 0) return (line, null);

  // TODO test case if ; is just last character

  // we treat all chars after ';' as a comment
  String comment = line.substring(commentStartIndex + 1, line.length);
  String remainingLine = line.substring(0, commentStartIndex);

  return (remainingLine, comment);
}
