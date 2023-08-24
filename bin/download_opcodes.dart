import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Purpose of this util is to format json containing 6502 opcodes to format
/// that servers better dax64 tools usage.
///
void main(List<String> args) async {
  print('download');

  final url =
      'https://raw.githubusercontent.com/ericTheEchidna/65C02-JSON/main/opcodes_65c02.json';
  final downloadedFile = await _downloadFile(url, 'opcodes_org.json');

  final json = await _readOpcodesJsonFile(downloadedFile.path);

  final Map<String, dynamic> finalJson = {};

  // 1. Instead of json starting with array, start with object. This way our
  //    code generation works.
  finalJson['instructions'] = json;

  for (var value in json) {
    final subJson = value as Map<String, dynamic>;

    // 2. Modify in place a map of opcodes to be a list of opcodes. This way
    //    we get opcode included into generated model classes.
    final Map<String, dynamic> opCodes = subJson['opcodes'];
    final finalOpcodes = [];
    subJson['opcodes'] = finalOpcodes;

    opCodes.forEach((opCode, opCodeJson) {
      opCodeJson['opcode'] = opCode;
      finalOpcodes.add(opCodeJson);
    });
  }

  await _saveOpcodesJsonFile(finalJson, 'opcodes.json');
}

Future<File> _downloadFile(String url, String filename) async {
  http.Client client = http.Client();
  var req = await client.get(Uri.parse(url));
  var bytes = req.bodyBytes;
  String dir = '.';
  File file = File('$dir/$filename');
  await file.writeAsBytes(bytes);
  return file;
}

Future<List<dynamic>> _readOpcodesJsonFile(String filePath) async {
  var input = await File(filePath).readAsString();
  var map = jsonDecode(input);
  return map;
}

Future _saveOpcodesJsonFile(Map<String, dynamic> json, String fileName) async {
  File file = File(fileName);
  const JsonEncoder encoder = JsonEncoder.withIndent('  ');
  await file.writeAsString(encoder.convert(json));
}
