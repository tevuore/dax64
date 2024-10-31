import 'package:dax64/assembler/assembler_config.dart';
import 'package:dax64/assembler/parser/parser.dart';
import 'package:dax64/models/generated/index.dart';
import 'package:dax64/models/statement/label.dart';
import 'package:dax64/opcodes_loader.dart';
import 'package:test/test.dart';

import 'parser_test_util.dart';

void main() {
  late Parser parser;
  setUp(() async {
    Opcodes opcodes = await readOpcodes();
    parser = Parser(config: AssemblerConfig(opcodes: opcodes));
  });

  test('should parse standalone label', () async {
    final input = r'LABEL1:';

    final program = parser.parse(input);
    final line = takeSingleLineFromSingleBlock(program);
    final label = line.statement as LabelStatement;

    expect(label.label, equals('LABEL1'));
    expect(line.comment, isNull);
  });

  test('should parse standalone label with indent', () async {
    final input = r'      LABEL1:';

    final program = parser.parse(input);
    final line = takeSingleLineFromSingleBlock(program);
    final label = line.statement as LabelStatement;

    expect(label.label, equals('LABEL1'));
    expect(line.comment, isNull);
  });

  test('should parse standalone label with trailing comment', () async {
    final input = r'LABEL1:                ; Loop starts here';

    final program = parser.parse(input);
    final line = takeSingleLineFromSingleBlock(program);
    final label = line.statement as LabelStatement;

    expect(label.label, equals('LABEL1'));
    // all after ';' char
    expect(line.comment, equals('Loop starts here'));
  });

  test('should parse statement with label ref to earlier def', () async {
    final input = r'''
    DATA:           .BYTE $FF
    MAIN:           LDY #$00
                    STA $DATA,y
    ''';

    final program = parser.parse(input);
    final lines = takeLines(program);
    expect(lines.length, equals(3));

    // take instruction that refers to label
    final instruction = toResolvedAssemblyInstruction(lines[2]);

    expect(instruction.hasLabel(), false);
    expect(instruction.instructionSpec.instruction, equals('STA'));
    expect(instruction.operand.value.isEmpty(), false);
    expect(instruction.operand!.value.getRawValue(), 'DATA');
  });

  test('should parse statement with label ref to later def', () async {
    // in white box testing, knowing how parsing is implemented it shouldn't
    // matter is label defined before or after. But to have a test for future
    // when more tests and refactoring.

    final input = r'''
    MAIN:           LDY #$00
                    JMP $JUMP
                    TYA
    JUMP:           LDY #$01
    ''';

    final program = parser.parse(input);
    final lines = takeLines(program);
    expect(lines.length, equals(4));

    // take instruction that refers to label
    final instruction = toResolvedAssemblyInstruction(lines[2]);

    expect(instruction.hasLabel(), false);
    expect(instruction.instructionSpec.instruction, equals('JMP'));
    expect(instruction.operand!.value.isEmpty(), false);
    expect(instruction.operand!.value.getRawValue(), 'JUMP');
  });
}
