import 'package:c64/assembler.dart';
import 'package:c64/command/command_base.dart';
import 'package:c64/errors.dart';
import 'package:c64/formatter/hex_formatter.dart';

class AssembleCommand extends CommandBase {
  @override
  final name = "assemble";
  @override
  final description = "Assembles assembly program to binary";

  AssembleCommand() {
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
    final input = await readInputStringFile();

    final assembler = Assembler();
    await assembler.initialize();
    final bytes = assembler.assemble(input);

    if (isOutputFileDefined()) {
      await writeHexCodesToOutputFile(bytes);
    } else {
      print(HexFormatter.format(bytes));
    }

    return 0;
  }
}
