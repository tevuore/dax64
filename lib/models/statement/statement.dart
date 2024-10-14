import 'package:dax64/assembler/errors.dart';

class Statement {
  final bool shouldAssemble;
  late final String? _label;

  // TODO should we have own type for label that prevents empty values
  Statement({required this.shouldAssemble, String? label}) {
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
}
