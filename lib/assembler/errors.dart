class AssemblerError extends Error {
  final String message;

  AssemblerError(this.message);

  @override
  String toString() {
    return 'AssemblerError: $message';
  }
}
