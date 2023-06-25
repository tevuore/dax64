class AssemblerError extends Error {
  final String message;

  AssemblerError(this.message);

  @override
  String toString() {
    return 'AssemblerError: $message';
  }
}

class NotImplementedAssemblerError extends AssemblerError {
  NotImplementedAssemblerError(super.message);

  @override
  String toString() {
    return 'NotImplementedAssemblerError: $message';
  }
}
