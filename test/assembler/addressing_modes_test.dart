import 'package:dax64/assembler/addressing_modes.dart';
import 'package:dax64/assembler/parser/operand_parser.dart';
import 'package:dax64/formatter/hex_formatter.dart';
import 'package:test/test.dart';

void main() {
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
    expect(value.getValue(), '05'); // TODO as raw value should we include $ ?
    expect(value.getIntValue(), equals(5));
    expect(value.toBytes().length, equals(1));
    expect(value.toBytes()[0], equals(5));
  });

  test('should parse absolute address mode', () async {
    final input = r'$1234';
    final (mode, value) = parseOperands(input);

    expect(mode, equals(AddressingMode.absolute));
    expect(value.getValue(), '1234');
    expect(value.getIntValue(), equals(4660));
    expect(value.toBytes().length, equals(2));
    expect(HexFormatter.format(value.toBytes()), equals('34 12'));
  });

  test('should parse absoluteX address mode', () async {
    final input = r'$1234,X';
    final (mode, value) = parseOperands(input);

    expect(mode, equals(AddressingMode.absoluteX));
    expect(HexFormatter.format(value.toBytes()), equals('34 12'));
  });

  test('should parse absoluteY address mode', () async {
    final input = r'$1234,Y';
    final (mode, value) = parseOperands(input);

    expect(mode, equals(AddressingMode.absoluteY));
    expect(HexFormatter.format(value.toBytes()), equals('34 12'));
  });

  test('should parse indirect address mode', () async {
    final input = r'($1234)';
    final (mode, value) = parseOperands(input);

    expect(mode, equals(AddressingMode.indirect));
    expect(HexFormatter.format(value.toBytes()), equals('34 12'));
  });

  test('should parse indirectX address mode', () async {
    final input = r'($12,X)';
    final (mode, value) = parseOperands(input);

    expect(mode, equals(AddressingMode.indirectX));
    expect(HexFormatter.format(value.toBytes()), equals('12'));
  });

  test('should parse indirectY address mode', () async {
    final input = r'($12),Y';
    final (mode, value) = parseOperands(input);

    expect(mode, equals(AddressingMode.indirectY));
    expect(HexFormatter.format(value.toBytes()), equals('12'));
  });

  test('should parse relative address mode', () async {
    final input = r'$1234';
    final (mode, value) = parseOperands(input);

    expect(mode, equals(AddressingMode.absolute));
    expect(HexFormatter.format(value.toBytes()), equals('34 12'));
  });

  test('should parse zeropage address mode', () async {
    final input = r'$12';
    final (mode, value) = parseOperands(input);

    expect(mode, equals(AddressingMode.zeropage));
    expect(HexFormatter.format(value.toBytes()), equals('12'));
  });

  test('should parse zeropageX address mode', () async {
    final input = r'$12,X';
    final (mode, value) = parseOperands(input);

    expect(mode, equals(AddressingMode.zeropageX));
    expect(HexFormatter.format(value.toBytes()), equals('12'));
  });

  test('should parse zeropageY address mode', () async {
    final input = r'$12,Y';
    final (mode, value) = parseOperands(input);

    expect(mode, equals(AddressingMode.zeropageY));
    expect(HexFormatter.format(value.toBytes()), equals('12'));
  });

  // TODO relative is not implemented, test for that
}
