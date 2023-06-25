import 'package:c64/assembler/assembler.dart';
import 'package:c64/formatter/hex_formatter.dart';
import 'package:c64/models/generated/index.dart';
import 'package:c64/opcodes_loader.dart';
import 'package:test/test.dart';

void main() {
  late Opcodes opcodes;
  late Assembler assembler;
  setUp(() async {
    opcodes = await readOpcodes();
    assembler = Assembler(opcodes: opcodes);
  });

  test('should assemble input to bytes', () async {
    final input = r'''
    LDY #$00       ; Load Y
    TYA            ; Transfer Y to Accumulator
    STA $0400,y    ; Store Accumulator
    LDA #$03       ; Load Accumulator
    STA $d800,y    ; Store Accumulator
    INY            ; Increment Y by one
    BNE #$f4       ; Branch if Result Not Zero
    RTS            ; Return from Subroutine
    ''';

    final bytes = assembler.assemble(input);

    final output = HexFormatter.format(bytes);
    print(output);
    expect(output, equals('A0 00 98 99 00 04 A9 03 99 00 D8 C8 D0 F4 60'));
  });

  test('should assemble immediate address mode', () async {
    final input = r'LDA #$05';
    final bytes = assembler.assemble(input);

    final output = HexFormatter.format(bytes);
    print(output);
    expect(output, equals('A9 05'));
  });
}
