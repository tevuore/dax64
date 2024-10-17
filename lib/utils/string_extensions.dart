extension StringExtensions on String {
  String dropLastChar() {
    return substring(0, length - 1);
  }

  bool isNotBlank() {
    return trim().isNotEmpty;
  }
}
