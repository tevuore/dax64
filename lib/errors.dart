class AssemblerError extends Error {
  final String message;

  AssemblerError(this.message);

  @override
  String toString() {
    return 'AssemblerError: $message';
  }
}

class InvalidInputError extends Error {
  final String message;

  InvalidInputError(this.message);

  @override
  String toString() {
    return 'InvalidInputError: $message';
  }
}
