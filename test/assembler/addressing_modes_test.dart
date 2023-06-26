import 'package:c64/assembler/addressing_modes.dart';
import 'package:test/test.dart';

void main() {
  test('should parse implied address mode', () async {
    final input = r'';
    final (mode, value) = parseOperands(input);

    expect(mode, equals(AddressingMode.implied));
    expect(value, isNull);
  });

  test('should parse accumulator address mode', () async {
    final input = r'A';
    final (mode, value) = parseOperands(input);

    expect(mode, equals(AddressingMode.accumulator));
    expect(value, isNull);
  });

  test('should parse immediate address mode', () async {
    final input = r'#$05';
    final (mode, value) = parseOperands(input);

    expect(mode, equals(AddressingMode.immediate));
    expect(value, equals('05'));
  });

  test('should parse absolute address mode', () async {
    final input = r'$1234';
    final (mode, value) = parseOperands(input);

    expect(mode, equals(AddressingMode.absolute));
    expect(value, equals('34 12'));
  });

  test('should parse absoluteX address mode', () async {
    final input = r'$1234,X';
    final (mode, value) = parseOperands(input);

    expect(mode, equals(AddressingMode.absoluteX));
    expect(value, equals('34 12'));
  });

  test('should parse absoluteY address mode', () async {
    final input = r'$1234,Y';
    final (mode, value) = parseOperands(input);

    expect(mode, equals(AddressingMode.absoluteY));
    expect(value, equals('34 12'));
  });

  test('should parse indirect address mode', () async {
    final input = r'($1234)';
    final (mode, value) = parseOperands(input);

    expect(mode, equals(AddressingMode.indirect));
    expect(value, equals('34 12'));
  });

  test('should parse indirectX address mode', () async {
    final input = r'($12,X)';
    final (mode, value) = parseOperands(input);

    expect(mode, equals(AddressingMode.indirectX));
    expect(value, equals('12'));
  });

  test('should parse indirectY address mode', () async {
    final input = r'($12),Y';
    final (mode, value) = parseOperands(input);

    expect(mode, equals(AddressingMode.indirectY));
    expect(value, equals('12'));
  });

  test('should parse relative address mode', () async {
    final input = r'$1234';
    final (mode, value) = parseOperands(input);

    expect(mode, equals(AddressingMode.absolute));
    expect(value, equals('34 12'));
  });

  test('should parse zeropage address mode', () async {
    final input = r'$12';
    final (mode, value) = parseOperands(input);

    expect(mode, equals(AddressingMode.zeropage));
    expect(value, equals('12'));
  });

  test('should parse zeropageX address mode', () async {
    final input = r'$12,X';
    final (mode, value) = parseOperands(input);

    expect(mode, equals(AddressingMode.zeropageX));
    expect(value, equals('12'));
  });

  test('should parse zeropageY address mode', () async {
    final input = r'$12,Y';
    final (mode, value) = parseOperands(input);

    expect(mode, equals(AddressingMode.zeropageY));
    expect(value, equals('12'));
  });
}
