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

// internal errors shouldn't happen, they are like assert errors but
class InternalAssemblerError extends AssemblerError {
  InternalAssemblerError(super.message);

  @override
  String toString() {
    return 'InternalAssemblerError: $message';
  }
}
