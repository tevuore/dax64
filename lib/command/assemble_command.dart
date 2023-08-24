import 'package:dax64/assembler/assembler.dart';
import 'package:dax64/command/command_base.dart';
import 'package:dax64/command/errors.dart';
import 'package:dax64/formatter/hex_formatter.dart';
import 'package:dax64/opcodes_loader.dart';

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
    final opcodes = await readOpcodes();

    final assembler = Assembler(opcodes: opcodes);
    final bytes = assembler.assemble(input);

    if (isOutputFileDefined()) {
      await writeHexCodesToOutputFile(bytes);
    } else {
      print(HexFormatter.format(bytes));
    }

    return 0;
  }
}
