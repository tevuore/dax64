import 'dart:io';
import 'dart:typed_data';

import 'package:args/command_runner.dart';
import 'package:c64/disassembler.dart';
import 'package:c64/errors.dart';
import 'package:c64/formatter/program_formatter.dart';

class DisassembleCommand extends Command {
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
  Future<int> run() async {
    try {
      // TODO generic checked
      if (!isInputFileDefined()) {
        throw InvalidInputError("Option 'input-file' is mandatory");
      }

      final bytes = await readBytes();

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
    } catch (e) {
      print(e);
      return 1;
    }
  }

  bool isInputFileDefined() {
    return argResults!.wasParsed('input-file');
  }

  bool isOutputFileDefined() {
    return argResults!.wasParsed('output-file');
  }

  Future writeToOutputFile(String data) async {
    final outputFile = argResults!['output-file'];
    File(outputFile).writeAsString(data);
  }

  Future<Uint8List> readBytes() async {
    final path = argResults!['input-file'];
    return await File(path).readAsBytes();
  }
}
