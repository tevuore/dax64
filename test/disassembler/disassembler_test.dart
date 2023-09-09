import 'dart:typed_data';

import 'package:dax64/disassembler/disassembler.dart';
import 'package:dax64/formatter/program_formatter.dart';
import 'package:dax64/models/generated/index.dart';
import 'package:dax64/opcodes_loader.dart';
import 'package:test/test.dart';

void main() {
  late Opcodes opcodes;
  late Disassembler disassembler;
  setUp(() async {
    opcodes = await readOpcodes();
    disassembler = Disassembler(opcodes: opcodes);
  });

  group("disassembler", () {
    test('should disassemble input', () async {
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

      final expected = r'''A0 00    LDY #$00; Load Y
98       TYA   ; Transfer Y to Accumulator
99 00 04 STA $0400,y; Store Accumulator
A9 03    LDA #$03; Load Accumulator
99 00 D8 STA $d800,y; Store Accumulator
C8       INY   ; Increment Y by one
D0 F4    BNE #$f4; Branch if Result Not Zero
60       RTS   ; Return from Subroutine
''';

      Uint8List bytes = Uint8List.fromList(input);

      final program = disassembler.disassemble(bytes);

      final output = ProgramFormatter.format(program,
          addInstructionDescription: true, addBytes: true);

      expect(output, equals(expected));
    });

    test('should disassemble input with short hex syntax', () async {
      final input = [
        0xA,
      ];

      Uint8List bytes = Uint8List.fromList(input);

      final program = disassembler.disassemble(bytes);
      expect(program.instructions[0].instruction.instruction, 'ASL');
    });
  });
}
