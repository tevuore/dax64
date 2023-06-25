import 'dart:io';
import 'dart:typed_data';

import 'package:args/command_runner.dart';
import 'package:c64/assembler.dart';
import 'package:c64/errors.dart';
import 'package:c64/formatter/hex_formatter.dart';

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
    try {
      // TODO generic checked, or just single input validation func
      if (!isInputFileDefined()) {
        throw InvalidInputError("Option 'input-file' is mandatory");
      }

      final input = await readInputFile();

      final assembler = Assembler();
      await assembler.initialize();
      final bytes = assembler.assemble(input);

      if (isOutputFileDefined()) {
        await writeHexCodesToOutputFile(bytes);
      } else {
        print(HexFormatter.format(bytes));
      }

      return 0;
    } catch (e, stacktrace) {
      // TODO with verbose flag print stacktrace
      print(e);
      print(stacktrace);
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

  Future<String> readInputFile() async {
    final path = argResults!['input-file'];
    return await File(path).readAsString();
  }

  // TODO common funcs between commands to single place
  Future writeHexCodesToOutputFile(Uint8List bytes) async {
    final outputFile = argResults!['output-file'];
    File(outputFile).writeAsBytes(bytes);
  }
}
