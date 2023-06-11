import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

void main(List<String> args) async {
  print('download');

  final url = 'https://raw.githubusercontent.com/ericTheEchidna/65C02-JSON/main/opcodes_65c02.json';
  final downloadedFile = await _downloadFile(url, 'opcodes_org.json');

  // TODO document why
  final json = await readOpcodesJsonFile(downloadedFile.path);

  final Map<String, dynamic> finalJson = {};

  finalJson['instructions'] = json;

  for (var value in json) {
    final subJson = value as Map<String, dynamic>;

    final Map<String, dynamic> opCodes = subJson['opcodes'];
    final finalOpcodes = [];
    subJson['opcodes'] = finalOpcodes;

    opCodes.forEach((opCode, opCodeJson) {
      print("$opCode - $opCodeJson");
      opCodeJson['opcode'] = opCode;
      finalOpcodes.add(opCodeJson);
    });
  }

  String dir = '.';
  String filename = 'opcodes.json';
  File file = File('$dir/$filename');
  const JsonEncoder encoder = JsonEncoder.withIndent('  ');
  await file.writeAsString(encoder.convert(finalJson));
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

Future<List<dynamic>> readOpcodesJsonFile(String filePath) async {
  var input = await File(filePath).readAsString();
  var map = jsonDecode(input);
  return map;
}