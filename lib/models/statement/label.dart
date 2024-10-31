import 'dart:collection';

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

  @override
  Map<String, dynamic> defs() {
    final map = HashMap<String, dynamic>();
    map[label] = this;
    return map;
  }

  @override
  Map<String, dynamic> refs() => HashMap();
}
