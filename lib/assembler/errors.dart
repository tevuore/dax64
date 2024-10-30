import 'package:meta/meta.dart';

@immutable
class SourceLine {
  final int lineNumber;
  final String raw;

  SourceLine(this.lineNumber, this.raw);
}

class AssemblerError extends Error {
  final String message;

  // TODO make line temporarily required to find out places where line info can be used
  final SourceLine? sourceLine;

  AssemblerError(this.message, [this.sourceLine]);

  @override
  String toString() {
    var msg = 'AssemblerError: $message';
    if (sourceLine != null) {
      msg += '\n${sourceLine!.lineNumber}: ${sourceLine!.raw}';
    }
    return msg;
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
  InternalAssemblerError(super.message, [super.sourceLine]);

  @override
  String toString() {
    // TODO any chance to reuse toString from AssemblerError
    var msg = 'InternalAssemblerError: $message';
    if (sourceLine != null) {
      msg += '\n${sourceLine!.lineNumber}: ${sourceLine!.raw}';
    }
    return msg;
  }
}
