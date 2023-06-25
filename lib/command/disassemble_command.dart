import 'package:c64/command/command_base.dart';
import 'package:c64/disassembler.dart';
import 'package:c64/errors.dart';
import 'package:c64/formatter/program_formatter.dart';

class DisassembleCommand extends CommandBase {
  @override
  final name = "disassemble";
  @override
  final description = "Disassembles binary file to 6502 assembly code";

  DisassembleCommand() {
    argParser.addOption('input-file');
    argParser.addOption('output-file');
    argParser.addFlag('add-instruction-description',
        abbr: 'i', negatable: false);
    argParser.addFlag('add-bytes', abbr: 'b', negatable: false);
  }

  @override
  void verifyInputs() {
    if (!isInputFileDefined()) {
      throw InvalidInputError("Option 'input-file' is mandatory");
    }
  }

  @override
  Future<int> runCommand() async {
    final bytes = await readInputBytesFile();

    final disassembler = Disassembler();
    await disassembler.initialize();

    final program = disassembler.disassemble(bytes);
    final output = ProgramFormatter.format(program,
        addInstructionDescription: argResults!['add-instruction-description'],
        addBytes: argResults!['add-bytes']);

    if (isOutputFileDefined()) {
      await writeToOutputFile(output);
    } else {
      print(output);
    }

    return 0;
  }
}
