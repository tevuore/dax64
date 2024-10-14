import 'package:dax64/models/statement/statement.dart';

/// Only label on line
class LabelStatement extends Statement {
  @override
  LabelStatement({required String label})
      : super(shouldAssemble: false, label: label);
}
