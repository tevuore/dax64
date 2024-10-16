import 'package:dax64/assembler/assembler_config.dart';
import 'package:dax64/assembler/parser/parser.dart';
import 'package:dax64/models/generated/index.dart';
import 'package:dax64/models/statement/macro.dart';
import 'package:dax64/opcodes_loader.dart';
import 'package:test/test.dart';

import 'parser_test_util.dart';

void main() {
  late Parser parser;
  setUp(() async {
    Opcodes opcodes = await readOpcodes();
    parser = Parser(config: AssemblerConfig(opcodes: opcodes));
  });

  test('should parse assignment', () async {
    final input = r'  FOO = $0200  ; characters';

    final program = parser.parse(input);
    final line = takeSingleLineFromSingleBlock(program);
    final assignment = line.statement as MacroAssignment;

    // TODO why there is no 'comment'
    //expect(assignment.comment, equals('characters'));
    expect(assignment.name, equals('FOO'));
    expect(assignment.value, equals(r'$0200'));

    // TODO why assignment can have label?
  });
}
