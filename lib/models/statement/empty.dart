import 'package:dax64/models/statement/statement.dart';

/// Models empty or plain comment line in assembly source code
class EmptyStatement extends Statement {
  EmptyStatement.empty() : super(shouldAssemble: false);
}
