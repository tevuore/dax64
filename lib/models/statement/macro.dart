import 'dart:collection';

import 'package:dax64/assembler/errors.dart';
import 'package:dax64/models/statement/statement.dart';
import 'package:dax64/utils/hex8bit.dart';
import 'package:meta/meta.dart';

class MacroStatement extends Statement {
  MacroStatement({super.label, required super.statementStr});

  @override
  bool get shouldAssemble => false;

  // TeroV impl
  @override
  bool isResolved() => false;

  // TBD macro is not yet implemented
  @override
  Map<String, dynamic> defs() => HashMap();

  @override
  Map<String, dynamic> refs() => HashMap();
}

@immutable
class MacroDefinition extends MacroStatement {
  final String name;

  MacroDefinition({
    required this.name,
    required super.statementStr,
  });

// TODO impl
}

@immutable
class MacroInvocation extends MacroStatement {
  MacroInvocation({required super.statementStr});
// TODO impl
}

@immutable
class MacroAssignment extends MacroStatement {
  final String name;
  final String valueStr;
  final int value; // TODO how to support different value types

  MacroAssignment(
      {required this.name,
      required this.valueStr,
      required this.value,
      required super.statementStr});

  // TODO sync with hex parsing funcs
  factory MacroAssignment.build(
      String name, String valueStr, String statementStr) {
    int value;
    if (valueStr.startsWith('0x') || valueStr.startsWith(r'$')) {
      final plainHexValue =
          valueStr.replaceFirst('0x', '').replaceFirst(r'$', '').trim();

      if (plainHexValue.isEmpty) {
        throw AssemblerError("Invalid hex value: $valueStr");
      }
      if (plainHexValue.length <= 2) {
        value = parse8BitHex(plainHexValue);
      } else if (plainHexValue.length <= 4) {
        final tryParsed = int.tryParse(plainHexValue, radix: 16);
        if (tryParsed == null) {
          throw AssemblerError("Invalid 16 bit hex value: $valueStr");
        }
        value = tryParsed;
      } else {
        throw AssemblerError("Hex value exceed 16 bit value: $plainHexValue");
      }
    } else {
      final tryParsed = int.tryParse(valueStr.trim(), radix: 10);
      if (tryParsed != null) {
        value = tryParsed;
      } else {
        throw AssemblerError("Unsupported macro value: $valueStr");
      }
    }

    // TBD other formats

    return MacroAssignment(
        name: name,
        valueStr: valueStr,
        value: value,
        statementStr: statementStr);
  }

  @override
  Map<String, dynamic> defs() {
    final map = HashMap<String, dynamic>();
    map[name] = this;
    return map;
  }

  @override
  Map<String, dynamic> refs() => HashMap();
}

enum MacroValueType {
  byte,
  word,
  dword,
}
