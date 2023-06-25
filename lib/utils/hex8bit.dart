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
