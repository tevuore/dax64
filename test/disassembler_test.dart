import 'dart:typed_data';

import 'package:c64/disassembler.dart';
import 'package:c64/program_formatter.dart';
import 'package:test/test.dart';

void main() {
  group("disassembler", () {
    test('should disassemble input', () async {
      // TODO can I have async setup?
      final disassembler = Disassembler();
      await disassembler.initialize();

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

      final program = disassembler.disassemble(bytes);

      final output = ProgramFormatter.format(program,
          addInstructionDescription: true, addBytes: true);
      print(output);
    });

    test('should disassemble input with short hex syntax', () async {
      // TODO can I have async setup?
      final disassembler = Disassembler();
      await disassembler.initialize();

      final input = [
        0xA,
      ];

      Uint8List bytes = Uint8List.fromList(input);

      final program = disassembler.disassemble(bytes);
      expect(program.instructions[0].instruction.instruction, 'ASL');
    });
  });
}
