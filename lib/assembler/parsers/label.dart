import 'package:dax64/assembler/errors.dart';

void validateLabel(String? label) {
  if (label == null) {
    return;
  }
  var regex = RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$');
  if (!regex.hasMatch(label)) {
    throw AssemblerError('Invalid label: $label');
  }
}
