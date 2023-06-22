import 'dart:typed_data';

import 'package:c64/models/generated/index.dart';
import 'package:c64/program_formatter.dart';
import 'package:test/test.dart';

void main() {
  test('should format with Immediate address mode', () {
    final opcode = buildOpcodeWithAddressMode('Immediate');
    expect(outputWithAddressMode(opcode, Uint8List.fromList([0x2F])), '#\$2f');
  });

  test('should format with Absolute address mode', () {
    final opcode = buildOpcodeWithAddressMode('Absolute');
    expect(outputWithAddressMode(opcode, Uint8List.fromList([0x2F, 0xAA])),
        '\$aa2f');
  });

  test('should format with Absolute,X address mode', () {
    final opcode = buildOpcodeWithAddressMode('Absolute, X');
    expect(outputWithAddressMode(opcode, Uint8List.fromList([0x2F, 0xAA])),
        '\$aa2f,x');
  });

  test('should format with Absolute,Y address mode', () {
    final opcode = buildOpcodeWithAddressMode('Absolute, Y');
    expect(outputWithAddressMode(opcode, Uint8List.fromList([0x2F, 0xAA])),
        '\$aa2f,y');
  });

  test('should format with Indirect address mode', () {
    final opcode = buildOpcodeWithAddressMode('(Indirect)');
    expect(outputWithAddressMode(opcode, Uint8List.fromList([0x2F, 0xAA])),
        '(\$aa2f)');
  });

  test('should format with Indirect,X address mode', () {
    final opcode = buildOpcodeWithAddressMode('(Indirect, X)');
    expect(outputWithAddressMode(opcode, Uint8List.fromList([0x2F, 0xAA])),
        '(\$aa2f),x');
  });

  test('should format with Indirect,Y address mode', () {
    final opcode = buildOpcodeWithAddressMode('(Indirect, Y)');
    expect(outputWithAddressMode(opcode, Uint8List.fromList([0x2F, 0xAA])),
        '(\$aa2f),y');
  });

  test('should format with Relative address mode', () {
    final opcode = buildOpcodeWithAddressMode('Relative');
    expect(outputWithAddressMode(opcode, Uint8List.fromList([0x06])), '\$0600');
  });

  test('should format with Zero Page address mode', () {
    final opcode = buildOpcodeWithAddressMode('Zero Page');
    expect(outputWithAddressMode(opcode, Uint8List.fromList([0x06])), '\$06');
  });

  test('should format with Zero Page,X address mode', () {
    final opcode = buildOpcodeWithAddressMode('Zero Page, X');
    expect(outputWithAddressMode(opcode, Uint8List.fromList([0x06])), '\$06,x');
  });

  test('should format with Zero Page,y address mode', () {
    final opcode = buildOpcodeWithAddressMode('Zero Page, Y');
    expect(outputWithAddressMode(opcode, Uint8List.fromList([0x06])), '\$06,y');
  });
}

// TODO any need for testing Accumulator and Implied address modes testing

Opcode buildOpcodeWithAddressMode(String addressMode) {
  return Opcode(
    opcode: '0x00',
    bytes: '1',
    cycles: '1',
    addressMode: addressMode,
  );
}
