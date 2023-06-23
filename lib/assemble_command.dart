import 'dart:io';
import 'dart:typed_data';

import 'package:args/command_runner.dart';
import 'package:c64/disassembler.dart';
import 'package:c64/program_formatter.dart';

class AssembleCommand extends Command {
  @override
  final name = "assemble";
  @override
  final description = "Assembles assembly program to binary";

  AssembleCommand() {
    argParser.addOption('input-file');
    argParser.addOption('output-file');
  }

  @override
  Future<int> run() async {
    // TODO generic checked
    if (!isInputFileDefined()) {
      print("ERROR: Option 'input-file' is mandatory");
      return 1;
    }

    final bytes = await readBytes();

    final disassembler = Disassembler();
    await disassembler.initialize();

    final program = disassembler.disassemble(bytes);
    final output = ProgramFormatter.format(
        program, argResults!['add-instruction-description']);

    if (isOutputFileDefined()) {
      await writeToOutputFile(output);
    } else {
      print(output);
    }

    return 0;
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