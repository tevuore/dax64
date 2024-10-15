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

  test('should parse standalone label with trailing comment', () async {
    final input = r'LABEL1:                ; Loop starts here';

    final program = parser.parse(input);
    final line = takeSingleLineFromSingleBlock(program);
    final label = line.statement as LabelStatement;

    expect(label.label, equals('LABEL1'));
    // all after ';' char
    expect(line.comment, equals('Loop starts here'));
  });
}

// TODO add test for label with indent, to both parsing methods
