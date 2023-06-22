import 'dart:typed_data';

import 'package:c64/parse_basic_data_command.dart';

class HexFormatter {
  static String format(Uint8List bytes) {
    List<String> hexCodes = bytes.map((number) => uint8ToHex(number)).toList();

    return hexCodes.join(' ');
  }
}
