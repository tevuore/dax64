import 'dart:typed_data';

import 'package:c64/basic/basic_loader.dart';
import 'package:test/test.dart';

void main() {
  group("basic loader", () {
    test('should wrap input bytes', () async {
      final loader = BasicLoader();

      final input = [
        0xA0,
        0x00,
        0x98,
        0x99,
        0x00,
        0x04,
        0xA9,
        0x03,
        0x99,
        0x00,
        0xD8,
        0xC8,
        0xD0,
        0xF4,
        0x60
      ];

      Uint8List bytes = Uint8List.fromList(input);

      final output = loader.wrap(bytes);
      print(output);
    });
  });
}
