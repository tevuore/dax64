import 'package:dax64/models/statement/statement.dart';

/// Only label on line
class LabelStatement extends Statement {
  LabelStatement({required super.label, required super.statementStr});

  factory LabelStatement.build(String statementStr) {
    return LabelStatement(
        label: statementStr.trim().replaceFirst(':', ''),
        statementStr: statementStr);
  }

  /// label should mark what is its memory address
  @override
  bool get shouldAssemble => true;

  @override
  bool isResolved() => true;
}
