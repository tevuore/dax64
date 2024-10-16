import 'package:dax64/assembler/assembler_config.dart';
import 'package:dax64/assembler/parser/parser.dart';
import 'package:dax64/models/generated/index.dart';
import 'package:dax64/models/statement/assembly.dart';
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

  test('should parse .BYTE', () async {
    final input = r'LABEL1:  .BYTE $00    ; starting char';

    final program = parser.parse(input);
    final line = takeSingleLineFromSingleBlock(program);
    final data = line as AssemblyData;

    expect(data.label, equals('LABEL1'));
    // TODO why there is no 'comment' field?
    //expect(data.comment, equals('characters'));
    expect(data.type, equals(MacroValueType.byte));
    expect(data..values.length, equals(1));
    // TODO depending on type there should be already some validation?
    expect(data.values[0], equals(r'$00'));
  });

  test('should parse .BYTE with multiple values', () async {
    final input = r'LABEL1:  .BYTE $00,$01,$02   ; characters';

    final program = parser.parse(input);
    final line = takeSingleLineFromSingleBlock(program);
    final data = line.statement as AssemblyData;

    expect(data.label, equals('LABEL1'));
    //expect(data.comment, equals('characters'));
    expect(data.type, equals(MacroValueType.byte));
    expect(data..values.length, equals(3));
    expect(data.values[0], equals(r'$00'));
    expect(data.values[1], equals(r'$01'));
    expect(data.values[2], equals(r'$02'));
  });
}
