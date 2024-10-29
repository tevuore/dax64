import 'package:dax64/models/statement/statement.dart';
import 'package:meta/meta.dart';

class MacroStatement extends Statement {
  MacroStatement({super.label}) : super(shouldAssemble: false);
}

@immutable
class MacroDefinition extends MacroStatement {
  final String name;

  MacroDefinition({
    required this.name,
  });

// TODO impl
}

@immutable
class MacroInvocation extends MacroStatement {
// TODO impl
}

@immutable
class MacroAssignment extends MacroStatement {
  final String name;
  final String value; // TODO how to support different value types

  MacroAssignment({
    required this.name,
    required this.value,
  });
}

enum MacroValueType {
  byte,
  word,
  dword,
}
