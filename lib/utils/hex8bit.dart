import 'dart:typed_data';

String uint8ToHex(int uint8) {
  return uint8.toRadixString(16).padLeft(2, '0').toUpperCase();
}

int parse8BitHex(String hex) {
  return int.parse(hex.replaceFirst('0x', ''), radix: 16);
}

int parseAsmHex(String hex) {
  return int.parse(hex.replaceFirst(r'$', ''), radix: 16);
}

Uint8List parse16BitHex(String hex) {
  if (hex.length != 4) {
    throw Exception('Invalid 16 bit hex: $hex');
  }
  return Uint8List.fromList([
    parse8BitHex(hex.substring(0, 2)),
    parse8BitHex(hex.substring(2, 4))
  ].reversed.toList());
}

Uint8List parseHex(String hex) {
  // remove prefixes
  var plainValue = hex.replaceFirst(r'$', '').replaceFirst('0x', 'x');

  if (plainValue.length > 2) {
    return Uint8List.fromList([
      parse8BitHex(hex.substring(0, 2)),
      parse8BitHex(hex.substring(2, 4))
    ].reversed.toList());
  }
  if (plainValue.length < 3) {
    return Uint8List.fromList([
      parse8BitHex(hex),
    ].reversed.toList());
  }

  throw Exception('Invalid hex value: $hex');
}

bool checkIsHexValue(String input) {
  RegExp regExp = RegExp(r'^(0x|\$)*[0-9a-fA-F]+$');
  return regExp.hasMatch(input);
}
