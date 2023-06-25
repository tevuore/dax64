import 'package:c64/addressing_modes.dart';
import 'package:c64/formatter/hex_formatter.dart';
import 'package:test/test.dart';

void main() {
  test('should parse implied address mode', () async {
    final input = r'';
    final (mode, bytes) = parseOperands(input);

    expect(mode, equals(AddressingMode.implied));
    expect(bytes.length, equals(0));
  });

  test('should parse accumulator address mode', () async {
    final input = r'A';
    final (mode, bytes) = parseOperands(input);

    expect(mode, equals(AddressingMode.accumulator));
    expect(bytes.length, equals(0));
  });

  test('should parse immediate address mode', () async {
    final input = r'#$05';
    final (mode, bytes) = parseOperands(input);

    expect(mode, equals(AddressingMode.immediate));
    expect(HexFormatter.format(bytes), equals('05'));
  });

  test('should parse absolute address mode', () async {
    final input = r'$1234';
    final (mode, bytes) = parseOperands(input);

    expect(mode, equals(AddressingMode.absolute));
    expect(HexFormatter.format(bytes), equals('34 12'));
  });

  test('should parse absoluteX address mode', () async {
    final input = r'$1234,X';
    final (mode, bytes) = parseOperands(input);

    expect(mode, equals(AddressingMode.absoluteX));
    expect(HexFormatter.format(bytes), equals('34 12'));
  });

  test('should parse absoluteY address mode', () async {
    final input = r'$1234,Y';
    final (mode, bytes) = parseOperands(input);

    expect(mode, equals(AddressingMode.absoluteY));
    expect(HexFormatter.format(bytes), equals('34 12'));
  });

  test('should parse indirect address mode', () async {
    final input = r'($1234)';
    final (mode, bytes) = parseOperands(input);

    expect(mode, equals(AddressingMode.indirect));
    expect(HexFormatter.format(bytes), equals('34 12'));
  });

  test('should parse indirectX address mode', () async {
    final input = r'($12,X)';
    final (mode, bytes) = parseOperands(input);

    expect(mode, equals(AddressingMode.indirectX));
    expect(HexFormatter.format(bytes), equals('12'));
  });

  test('should parse indirectY address mode', () async {
    final input = r'($12),Y';
    final (mode, bytes) = parseOperands(input);

    expect(mode, equals(AddressingMode.indirectY));
    expect(HexFormatter.format(bytes), equals('12'));
  });

  test('should parse relative address mode', () async {
    final input = r'$1234';
    final (mode, bytes) = parseOperands(input);

    expect(mode, equals(AddressingMode.absolute));
    expect(HexFormatter.format(bytes), equals('34 12'));
  });

  test('should parse zeropage address mode', () async {
    final input = r'$12';
    final (mode, bytes) = parseOperands(input);

    expect(mode, equals(AddressingMode.zeropage));
    expect(HexFormatter.format(bytes), equals('12'));
  });

  test('should parse zeropageX address mode', () async {
    final input = r'$12,X';
    final (mode, bytes) = parseOperands(input);

    expect(mode, equals(AddressingMode.zeropageX));
    expect(HexFormatter.format(bytes), equals('12'));
  });

  test('should parse zeropageY address mode', () async {
    final input = r'$12,Y';
    final (mode, bytes) = parseOperands(input);

    expect(mode, equals(AddressingMode.zeropageY));
    expect(HexFormatter.format(bytes), equals('12'));
  });
}
