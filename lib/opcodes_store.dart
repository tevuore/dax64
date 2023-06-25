import 'dart:convert';
import 'dart:io';

import 'package:c64/models/generated/index.dart';

Future<Opcodes> readOpcodes() async {
  return readOpcodeJsonFile('assets/opcodes.json');
}

Future<Opcodes> readOpcodeJsonFile(String filePath) async {
  var input = await File(filePath).readAsString();
  var map = jsonDecode(input);
  return Opcodes.fromJson(map);
}
