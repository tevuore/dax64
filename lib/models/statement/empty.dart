import 'dart:collection';

import 'package:dax64/models/statement/statement.dart';

/// Models empty or plain comment line in assembly source code
class EmptyStatement extends Statement {
  EmptyStatement.empty()
      : super(statementStr: ''); // TODO makes sense to have empty string

  @override
  bool get shouldAssemble => false;

  @override
  bool isResolved() => true;

  @override
  Map<String, dynamic> defs() => HashMap();

  @override
  Map<String, dynamic> refs() => HashMap();
}
