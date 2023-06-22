import 'dart:io';
import 'dart:typed_data';

import 'package:args/command_runner.dart';
import 'package:c64/basic_parser.dart' as basic_parser;
import 'package:c64/hex_formatter.dart';

class ParseBasicDataCommand extends Command {
  @override
  final name = "parsebasicdata";
  @override
  final description = "Parses Basic DATA statements and outputs binary file";

  ParseBasicDataCommand() {
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

    final bytes = basic_parser.parse(await readInputFile());

    if (isOutputFileDefined()) {
      await writeHexCodesToOutputFile(bytes);
    } else {
      print(HexFormatter.format(bytes));
    }

    return 0;
  }

  bool isInputFileDefined() {
    return argResults!.wasParsed('input-file');
  }

  bool isOutputFileDefined() {
    return argResults!.wasParsed('output-file');
  }

  Future writeHexCodesToOutputFile(Uint8List bytes) async {
    final outputFile = argResults!['output-file'];
    File(outputFile).writeAsBytes(bytes);
  }

  Future<String> readInputFile() async {
    final path = argResults!['input-file'];
    return await File(path).readAsString();
  }
}

// TODO move to utils package
String uint8ToHex(int uint8) {
  return uint8.toRadixString(16).padLeft(2, '0').toUpperCase();
}