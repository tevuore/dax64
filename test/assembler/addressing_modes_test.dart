import 'package:dax64/assembler/addressing_modes.dart';
import 'package:dax64/assembler/parser/operand_parser.dart';
import 'package:dax64/formatter/hex_formatter.dart';
import 'package:test/test.dart';

void main() {
  group('direct value', () {
    test('should parse implied address mode', () async {
      final input = r'';
      final (mode, value) = parseOperands(input);

      expect(mode, equals(AddressingMode.implied));
      expect(value.isEmpty(), true);
    });

    test('should parse accumulator address mode', () async {
      final input = r'A';
      final (mode, value) = parseOperands(input);

      expect(mode, equals(AddressingMode.accumulator));
      expect(value.isEmpty(), true);
    });

    test('should parse immediate address mode', () async {
      final input = r'#$05';
      final (mode, value) = parseOperands(input);

      expect(mode, equals(AddressingMode.immediate));
      expect(value.getRawValue(),
          r'$05'); // TODO as raw value should we include $ ?
      expect(value.getIntValue(), equals(5));
      expect(value.toBytes().length, equals(1));
      expect(value.toBytes()[0], equals(5));
    });

    test('should parse absolute address mode', () async {
      final input = r'$1234';
      final (mode, value) = parseOperands(input);

      expect(mode, equals(AddressingMode.absolute));
      expect(value.getRawValue(), r'$1234');
      expect(value.getIntValue(), equals(4660));
      expect(value.toBytes().length, equals(2));
      expect(HexFormatter.format(value.toBytes()), equals('34 12'));
    });

    test('should parse absoluteX address mode', () async {
      final input = r'$1234,X';
      final (mode, value) = parseOperands(input);

      expect(mode, equals(AddressingMode.absoluteX));
      expect(value.getRawValue(), r'$1234');
      expect(HexFormatter.format(value.toBytes()), equals('34 12'));
    });

    test('should parse absoluteY address mode', () async {
      final input = r'$1234,Y';
      final (mode, value) = parseOperands(input);

      expect(mode, equals(AddressingMode.absoluteY));
      expect(value.getRawValue(), r'$1234');
      expect(HexFormatter.format(value.toBytes()), equals('34 12'));
    });

    test('should parse indirect address mode', () async {
      final input = r'($1234)';
      final (mode, value) = parseOperands(input);

      expect(mode, equals(AddressingMode.indirect));
      expect(value.getRawValue(), r'$1234');
      expect(HexFormatter.format(value.toBytes()), equals('34 12'));
    });

    test('should parse indirectX address mode', () async {
      final input = r'($12,X)';
      final (mode, value) = parseOperands(input);

      expect(mode, equals(AddressingMode.indirectX));
      expect(value.getRawValue(), r'$12');
      expect(HexFormatter.format(value.toBytes()), equals('12'));
    });

    test('should parse indirectY address mode', () async {
      final input = r'($12),Y';
      final (mode, value) = parseOperands(input);

      expect(mode, equals(AddressingMode.indirectY));
      expect(value.getRawValue(), r'$12');
      expect(HexFormatter.format(value.toBytes()), equals('12'));
    });

    test('should parse zeropage address mode', () async {
      final input = r'$12';
      final (mode, value) = parseOperands(input);

      expect(mode, equals(AddressingMode.zeropage));
      expect(value.getRawValue(), r'$12');
      expect(HexFormatter.format(value.toBytes()), equals('12'));
    });

    test('should parse zeropageX address mode', () async {
      final input = r'$12,X';
      final (mode, value) = parseOperands(input);

      expect(mode, equals(AddressingMode.zeropageX));
      expect(value.getRawValue(), r'$12');
      expect(HexFormatter.format(value.toBytes()), equals('12'));
    });

    test('should parse zeropageY address mode', () async {
      final input = r'$12,Y';
      final (mode, value) = parseOperands(input);

      expect(mode, equals(AddressingMode.zeropageY));
      expect(value.getRawValue(), r'$12');
      expect(HexFormatter.format(value.toBytes()), equals('12'));
    });

    // TODO relative is not implemented, test for that
  });

  group('ref value', () {
    test('should parse address ref immediate address', () async {
      final input = r'#LOOP';
      final (mode, value) = parseOperands(input);

      expect(mode, equals(AddressingMode.immediate));
      expect(value.getRawValue(), 'LOOP');
    });

    test('should parse absolute address mode', () async {
      final input = r'LOOP';
      final (mode, value) = parseOperands(input);

      expect(mode, equals(AddressingMode.absolute));
      expect(value.getRawValue(), 'LOOP');
    });

    test('should parse absoluteX address mode', () async {
      final input = r'JUMP_TABLE,X';
      final (mode, value) = parseOperands(input);

      expect(mode, equals(AddressingMode.absoluteX));
      expect(value.getRawValue(), 'JUMP_TABLE');
    });

    test('should parse absoluteY address mode', () async {
      final input = r'JUMP_TABLE,Y';
      final (mode, value) = parseOperands(input);

      expect(mode, equals(AddressingMode.absoluteY));
      expect(value.getRawValue(), 'JUMP_TABLE');
    });

    test('should parse indirect address mode', () async {
      final input = r'(JUMP_TABLE)';
      final (mode, value) = parseOperands(input);

      expect(mode, equals(AddressingMode.indirect));
      expect(value.getRawValue(), 'JUMP_TABLE');
    });

    test('should parse indirectX address mode', () async {
      final input = r'(JUMP_TABLE,X)';
      final (mode, value) = parseOperands(input);

      expect(mode, equals(AddressingMode.indirectX));
      expect(value.getRawValue(), 'JUMP_TABLE');
    });

    test('should parse indirectY address mode', () async {
      final input = r'(JUMP_TABLE),Y';
      final (mode, value) = parseOperands(input);

      expect(mode, equals(AddressingMode.indirectY));
      expect(value.getRawValue(), 'JUMP_TABLE');
    });

    // TeroV you can't know at this point what addressing mode?

    //  => for ref values we may need to delay parsing addressing mode...
    //     then we need to have higher level tests that zeropage addressing mode is parsed
    test('should parse zeropage address mode', () async {
      final input = r'$ZEROPAGE';
      final (mode, value) = parseOperands(input);

      expect(mode, equals(AddressingMode.zeropage));
      expect(value.getRawValue(), 'ZEROPAGE');
    });

    test('should parse zeropageX address mode', () async {
      final input = r'ZEROPAGE,X';
      final (mode, value) = parseOperands(input);

      expect(mode, equals(AddressingMode.zeropageX));
      expect(value.getRawValue(), 'ZEROPAGE');
    });

    test('should parse zeropageY address mode', () async {
      final input = r'ZEROPAGE,Y';
      final (mode, value) = parseOperands(input);

      expect(mode, equals(AddressingMode.zeropageY));
      expect(value.getRawValue(), 'ZEROPAGE');
    });
  });
}
