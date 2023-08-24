import 'package:dax64/assembler/addressing_modes.dart';
import 'package:dax64/assembler/parser.dart';
import 'package:dax64/formatter/hex_formatter.dart';
import 'package:dax64/models/asm_program.dart';
import 'package:dax64/models/generated/index.dart';
import 'package:dax64/opcodes_loader.dart';
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

    final lines = parser.parse(input).blocks[0].lines;
    expect(lines.length, equals(9)); // last empty line included
  });

  test('should parse opcode', () async {
    final input = r'LDY #$00       ; Load Y';

    final program = parser.parse(input);
    final line = takeSingleLineFromSingleBlock(program);
    final instruction = toAssemblyInstruction(line);

    expect(instruction.label, isNull);
    expect(instruction.instructionSpec.instruction, equals('LDY'));
    expect(HexFormatter.format(instruction.operand!.value.toBytes()),
        equals('00'));
    expect(line.comment, equals('Load Y'));
  });

  test('should parse opcode without operand', () async {
    final input = r'  RTS       ; Return from subroutine';

    final program = parser.parse(input);
    final line = takeSingleLineFromSingleBlock(program);
    final instruction = toAssemblyInstruction(line);

    expect(instruction.label, isNull);
    expect(instruction.instructionSpec.instruction, equals('RTS'));
    expect(instruction.operand!.value.isEmpty(), true);
    expect(instruction.operand!.addressingMode, equals(AddressingMode.implied));
    expect(line.comment, equals('Return from subroutine'));
  });

  test('should parse opcode with label', () async {
    final input = r'LABEL1  LDY #$00       ; Load Y';

    final program = parser.parse(input);
    final line = takeSingleLineFromSingleBlock(program);
    final instruction = toAssemblyInstruction(line);

    expect(instruction.label, equals('LABEL1'));
    expect(instruction.instructionSpec.instruction, equals('LDY'));
    expect(HexFormatter.format(instruction.operand!.value.toBytes()),
        equals('00'));
    expect(line.comment, equals('Load Y'));
  });

  // TODO how this should be handled
  // test('should parse label line', () async {
  //   final input = r'LABEL1';
  //
  //   final program = parser.parse(input);
  //   final line = takeSingleLineFromSingleBlock(program);
  //   final instruction = toAssemblyInstruction(line);
  //
  //   expect(instruction.label, equals('LABEL1'));
  // });

  test('should parse comment line', () async {
    final input = r'  ; some comment ';

    final program = parser.parse(input);
    final line = takeSingleLineFromSingleBlock(program);

    // TODO test something is null
    expect(line.comment, equals('some comment'));
  });

  test('should ignore empty line with whitespace', () async {
    final input = r'  ';

    final program = parser.parse(input);
    // empty lines are included
    expect(program.blocks.length, equals(1));
    expect(program.blocks[0].lines.length, equals(1));
  });

  // TODO test
  // test('should parse .BYTE with multiple values', () async {
  //   final input = r'LABEL1  .BYTE $00,$01,$02   ; characters';
  //
  //   final program = parser.parse(input);
  //   final line = takeSingleLineFromSingleBlock(program);
  //   final instruction = toAssemblyInstruction(line);
  //
  //   expect(instruction.label, equals('LABEL1'));
  //   expect(elements[0].instruction, equals('.BYTE'));
  //   expect(elements[0].operand, equals(r'$00,$01,$02'));
  //   expect(elements[0].comment, equals('characters'));
  // });

  // TODO impl
  // test('should parse .BYTE', () async {
  //   final input = r'LABEL1  .BYTE $00    ; starting char';
  //
  //   final program = parser.parse(input);
  //   final line = takeSingleLineFromSingleBlock(program);
  //   final instruction = toAssemblyInstruction(line);
  //
  //   expect(instruction.label, equals('LABEL1'));
  //   expect(elements[0].instruction, equals('.BYTE'));
  //   expect(elements[0].operand, equals(r'$00'));
  //   expect(elements[0].comment, equals('starting char'));
  // });
}

AssemblyInstruction extractSingleAssemblyInstruction(AsmProgram program) {
  final lines = program.blocks[0].lines;
  expect(lines.length, equals(1));
  return lines[0].statement as AssemblyInstruction;
}

/// utility function to extract parsed line information
AsmProgramLine takeSingleLineFromSingleBlock(AsmProgram program) {
  expect(program.blocks.length, equals(1));
  expect(program.blocks[0].lines.length, equals(1));
  return program.blocks[0].lines[0];
}

AssemblyInstruction toAssemblyInstruction(AsmProgramLine line) {
  return line.statement as AssemblyInstruction;
}
