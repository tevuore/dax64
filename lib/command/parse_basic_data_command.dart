import 'package:c64/basic/basic_parser.dart' as basic_parser;
import 'package:c64/command/command_base.dart';
import 'package:c64/command/errors.dart';
import 'package:c64/formatter/hex_formatter.dart';

class ParseBasicDataCommand extends CommandBase {
  @override
  final name = "parsebasicdata";
  @override
  final description = "Parses Basic DATA statements and outputs binary file";

  ParseBasicDataCommand() {
    argParser.addOption('input-file');
    argParser.addOption('output-file');
  }

  @override
  void verifyInputs() {
    if (!isInputFileDefined()) {
      throw InvalidInputError("Option 'input-file' is mandatory");
    }
  }

  @override
  Future<int> runCommand() async {
    final bytes = basic_parser.parse(await readInputStringFile());

    if (isOutputFileDefined()) {
      await writeHexCodesToOutputFile(bytes);
    } else {
      print(HexFormatter.format(bytes));
    }

    return 0;
  }
}
