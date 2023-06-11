


import 'dart:typed_data';

import 'package:c64/models/index.dart';
import 'package:meta/meta.dart';

@immutable
class InstructionInstance {
  final Instruction instruction;
  final Opcode opcode;
  final Uint8List bytes;

  InstructionInstance({
    required this.instruction,
    required this.opcode,
    required Uint8List instructionBytes}) : bytes = UnmodifiableUint8ListView(instructionBytes);
}

class InstructionSet {

}

class Program {

}

