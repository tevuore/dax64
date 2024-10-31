import 'package:dax64/assembler/errors.dart';

abstract class Statement {
  // after comment and trimming, real payload of line what is left
  late final String statementStr;
  late final String? _label;

  // TODO should we have own type for label that prevents empty values => we could have this class abstract
  Statement({required this.statementStr, String? label}) {
    if (label != null && label.trim().isEmpty) {
      throw InternalAssemblerError('Label should not be blank');
    }
    _label = label;
  }

  String get label {
    if (_label == null) {
      throw AssemblerError('Statement has no label');
    }
    return _label;
  }

  bool hasLabel() => _label != null;

  bool isResolved();

  bool get shouldAssemble;

  // dynamic defs: label, variable definition, macro definitions
  Map<String, dynamic> defs();

  // dynamic refs: label ref or variable ref and macro invocation
  Map<String, dynamic> refs();
}
