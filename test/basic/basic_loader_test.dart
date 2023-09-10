import 'dart:typed_data';

import 'package:dax64/basic/basic_loader.dart';
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

      final expected = '''10 REM *** LOADER ***
20 FOR I=0 TO 14
30 READ A
40 POKE 49152+I,A
50 NEXT I
60 SYS 49152
70 DATA 160,0,152,153,0,4,169,3,153,0,216,200,208,244,96
''';

      Uint8List bytes = Uint8List.fromList(input);

      final output = loader.wrap(bytes);
      expect(output, equals(expected));
    });
  });
}
