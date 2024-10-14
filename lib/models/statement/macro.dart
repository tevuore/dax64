import 'package:dax64/models/statement/statement.dart';

class MacroStatement extends Statement {
  MacroStatement({super.label}) : super(shouldAssemble: false);
}

class MacroDefinition extends MacroStatement {
  // TODO impl
}

class MacroInvocation extends MacroStatement {
// TODO impl
}

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
