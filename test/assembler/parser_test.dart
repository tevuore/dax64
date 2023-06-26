import 'package:c64/assembler/parser.dart';
import 'package:c64/models/generated/index.dart';
import 'package:c64/opcodes_loader.dart';
import 'package:test/test.dart';

void main() {
  late Opcodes opcodes;
  late Parser parser;
  setUp(() async {
    opcodes = await readOpcodes();
    parser = Parser(opcodes: opcodes);
  });

  test('should parse multiple lines', () async {
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

    final elements = parser.parse(input);
    expect(elements.length, equals(8));
  });

  test('should parse opcode', () async {
    final input = r'LDY #$00       ; Load Y';

    final elements = parser.parse(input);
    expect(elements.length, equals(1));
    expect(elements[0].label, isNull);
    expect(elements[0].instruction, equals('LDY'));
    expect(elements[0].operand, equals(r'#$00'));
    expect(elements[0].comment, equals('Load Y'));
  });

  test('should parse opcode without operand', () async {
    final input = r'  RTS       ; Return from subroutine';

    final elements = parser.parse(input);
    expect(elements.length, equals(1));
    expect(elements[0].label, isNull);
    expect(elements[0].instruction, equals('RTS'));
    expect(elements[0].operand, isNull);
    expect(elements[0].comment, equals('Return from subroutine'));
  });

  test('should parse opcode with label', () async {
    final input = r'LABEL1  LDY #$00       ; Load Y';

    final elements = parser.parse(input);
    expect(elements.length, equals(1));
    expect(elements[0].label, equals('LABEL1'));
    expect(elements[0].instruction, equals('LDY'));
    expect(elements[0].operand, equals(r'#$00'));
    expect(elements[0].comment, equals('Load Y'));
  });

  test('should parse label line', () async {
    final input = r'LABEL1';

    final elements = parser.parse(input);
    expect(elements.length, equals(1));
    expect(elements[0].label, equals('LABEL1'));
    expect(elements[0].instruction, isNull);
    expect(elements[0].operand, isNull);
    expect(elements[0].comment, isNull);
  });

  test('should parse comment line', () async {
    final input = r'  ; some comment ';

    final elements = parser.parse(input);
    expect(elements.length, equals(1));
    expect(elements[0].label, isNull);
    expect(elements[0].instruction, isNull);
    expect(elements[0].operand, isNull);
    expect(elements[0].comment, equals('some comment'));
  });

  test('should ignore empty line with whitespace', () async {
    final input = r'  ';

    final elements = parser.parse(input);
    expect(elements.length, equals(0));
  });
}
