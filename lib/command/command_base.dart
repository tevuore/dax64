import 'dart:io';
import 'dart:typed_data';

import 'package:args/command_runner.dart';

abstract class CommandBase extends Command {
  void verifyInputs();

  Future<int> runCommand();

  @override
  Future<int> run() async {
    try {
      verifyInputs();
      return await runCommand();
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

  Future writeHexCodesToOutputFile(Uint8List bytes) async {
    final outputFile = argResults!['output-file'];
    File(outputFile).writeAsBytes(bytes);
  }

  Future<Uint8List> readInputBytesFile() async {
    final path = argResults!['input-file'];
    return await File(path).readAsBytes();
  }

  Future<String> readInputStringFile() async {
    final path = argResults!['input-file'];
    return await File(path).readAsString();
  }
}
