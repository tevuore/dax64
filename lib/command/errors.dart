class InvalidInputError extends Error {
  final String message;

  InvalidInputError(this.message);

  @override
  String toString() {
    return 'InvalidInputError: $message';
  }
}
