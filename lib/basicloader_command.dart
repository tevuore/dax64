import 'dart:io';
import 'dart:typed_data';

import 'package:args/command_runner.dart';
import 'package:c64/basic_loader.dart';
import 'package:c64/errors.dart';

class BasicLoaderCommand extends Command {
  @override
  final name = "basicloader";
  @override
  final description = "Wraps bytes into a BASIC loader";

  BasicLoaderCommand() {
    argParser.addOption('input-file');
    argParser.addOption('output-file');
  }

  @override
  Future<int> run() async {
    try {
      // TODO generic checked
      if (!isInputFileDefined()) {
        throw InvalidInputError("Option 'input-file' is mandatory");
      }

      final bytes = await readBytes();

      final loader = BasicLoader();
      final output = loader.wrap(bytes);

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
