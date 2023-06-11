import 'dart:io';
import 'package:c64/basic_parser.dart' as basic_parser;
import 'package:args/command_runner.dart';

class ParseBasicDataCommand extends Command {
  @override
  final name = "parsebasicdata";
  @override
  final description = "Parses Basic DATA statements and outputs binary file";

  ParseBasicDataCommand() {
    argParser.addOption('input-file');
  }

  @override
  Future<int> run() async {
    // TODO generic checked
    if (!argResults!.wasParsed('input-file')) {
      print("ERROR: Option 'input-file' is mandatory");
      return 1;
    }

    final path = argResults!['input-file'];
    final data = await File(path).readAsString();
    final numbers = basic_parser.parse(data);

    List<String> hexCodes = numbers.map((number) => uint8ToHex(number)).toList();
    print(hexCodes);

    return 0;
  }

}

String uint8ToHex(int uint8) {
  return uint8.toRadixString(16).padLeft(2, '0').toUpperCase();
}