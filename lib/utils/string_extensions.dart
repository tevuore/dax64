extension StringExtensions on String {
  String dropLastChar() {
    return substring(0, length - 1);
  }
}
