import 'dart:typed_data';

import 'package:dax64/models/generated/index.dart';
import 'package:meta/meta.dart';

class DisasmProgram {
  final List<InstructionInstance> instructions = [];
}

@immutable
class InstructionInstance {
  final Instruction instruction;
  final Opcode opcode;
  final Uint8List paramBytes;

  InstructionInstance(
      {required this.instruction,
      required this.opcode,
      required Uint8List instructionBytes})
      : paramBytes = instructionBytes.asUnmodifiableView();
}

class InstructionSet {}
