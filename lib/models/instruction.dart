


import 'dart:typed_data';

import 'package:c64/models/generated/index.dart';
import 'package:meta/meta.dart';

@immutable
class InstructionInstance {
  final Instruction instruction;
  final Opcode opcode;
  final Uint8List paramBytes;

  InstructionInstance({
    required this.instruction,
    required this.opcode,
    required Uint8List instructionBytes}) : paramBytes = UnmodifiableUint8ListView(instructionBytes);
}

class InstructionSet {

}

class Program {
  final List<InstructionInstance> instructions = [];
}

