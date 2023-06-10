import 'package:meta/meta.dart';
import 'package:quiver/core.dart';


import 'index.dart';

@immutable
class Opcodes {

  const Opcodes({
    required this.instructions,
  });

  final List<Instruction> instructions;

  factory Opcodes.fromJson(Map<String,dynamic> json) => Opcodes(
    instructions: (json['instructions'] as List? ?? []).map((e) => Instruction.fromJson(e as Map<String, dynamic>)).toList()
  );
  
  Map<String, dynamic> toJson() => {
    'instructions': instructions.map((e) => e.toJson()).toList()
  };

  Opcodes clone() => Opcodes(
    instructions: instructions.map((e) => e.clone()).toList()
  );


  Opcodes copyWith({
    List<Instruction>? instructions
  }) => Opcodes(
    instructions: instructions ?? this.instructions,
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is Opcodes && instructions == other.instructions;

  @override
  int get hashCode => instructions.hashCode;
}

@immutable
class Instruction {

  const Instruction({
    required this.instruction,
    required this.description,
    required this.flags,
    required this.opcodes,
  });

  final String instruction;
  final String description;
  final Flags flags;
  final List<Opcode> opcodes;

  factory Instruction.fromJson(Map<String,dynamic> json) => Instruction(
    instruction: json['instruction'].toString(),
    description: json['description'].toString(),
    flags: Flags.fromJson(json['flags'] as Map<String, dynamic>),
    opcodes: (json['opcodes'] as List? ?? []).map((e) => Opcode.fromJson(e as Map<String, dynamic>)).toList()
  );
  
  Map<String, dynamic> toJson() => {
    'instruction': instruction,
    'description': description,
    'flags': flags.toJson(),
    'opcodes': opcodes.map((e) => e.toJson()).toList()
  };

  Instruction clone() => Instruction(
    instruction: instruction,
    description: description,
    flags: flags.clone(),
    opcodes: opcodes.map((e) => e.clone()).toList()
  );


  Instruction copyWith({
    String? instruction,
    String? description,
    Flags? flags,
    List<Opcode>? opcodes
  }) => Instruction(
    instruction: instruction ?? this.instruction,
    description: description ?? this.description,
    flags: flags ?? this.flags,
    opcodes: opcodes ?? this.opcodes,
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is Instruction && instruction == other.instruction && description == other.description && flags == other.flags && opcodes == other.opcodes;

  @override
  int get hashCode => instruction.hashCode ^ description.hashCode ^ flags.hashCode ^ opcodes.hashCode;
}

@immutable
class Flags {

  const Flags({
    required this.negative,
    required this.zero,
    required this.carry,
    required this.interrupt,
    required this.decimal,
    required this.overflow,
  });

  final String negative;
  final String zero;
  final String carry;
  final String interrupt;
  final String decimal;
  final String overflow;

  factory Flags.fromJson(Map<String,dynamic> json) => Flags(
    negative: json['Negative'].toString(),
    zero: json['Zero'].toString(),
    carry: json['Carry'].toString(),
    interrupt: json['Interrupt'].toString(),
    decimal: json['Decimal'].toString(),
    overflow: json['Overflow'].toString()
  );
  
  Map<String, dynamic> toJson() => {
    'Negative': negative,
    'Zero': zero,
    'Carry': carry,
    'Interrupt': interrupt,
    'Decimal': decimal,
    'Overflow': overflow
  };

  Flags clone() => Flags(
    negative: negative,
    zero: zero,
    carry: carry,
    interrupt: interrupt,
    decimal: decimal,
    overflow: overflow
  );


  Flags copyWith({
    String? negative,
    String? zero,
    String? carry,
    String? interrupt,
    String? decimal,
    String? overflow
  }) => Flags(
    negative: negative ?? this.negative,
    zero: zero ?? this.zero,
    carry: carry ?? this.carry,
    interrupt: interrupt ?? this.interrupt,
    decimal: decimal ?? this.decimal,
    overflow: overflow ?? this.overflow,
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is Flags && negative == other.negative && zero == other.zero && carry == other.carry && interrupt == other.interrupt && decimal == other.decimal && overflow == other.overflow;

  @override
  int get hashCode => negative.hashCode ^ zero.hashCode ^ carry.hashCode ^ interrupt.hashCode ^ decimal.hashCode ^ overflow.hashCode;
}

@immutable
class Opcode {

  const Opcode({
    required this.opcode,
    required this.addressMode,
    required this.bytes,
    required this.cycles,
  });

  final String opcode;
  final String addressMode;
  final String bytes;
  final String cycles;

  factory Opcode.fromJson(Map<String,dynamic> json) => Opcode(
    opcode: json['opcode'].toString(),
    addressMode: json['address_mode'].toString(),
    bytes: json['bytes'].toString(),
    cycles: json['cycles'].toString()
  );
  
  Map<String, dynamic> toJson() => {
    'opcode': opcode,
    'address_mode': addressMode,
    'bytes': bytes,
    'cycles': cycles
  };

  Opcode clone() => Opcode(
    opcode: opcode,
    addressMode: addressMode,
    bytes: bytes,
    cycles: cycles
  );


  Opcode copyWith({
    String? opcode,
    String? addressMode,
    String? bytes,
    String? cycles
  }) => Opcode(
    opcode: opcode ?? this.opcode,
    addressMode: addressMode ?? this.addressMode,
    bytes: bytes ?? this.bytes,
    cycles: cycles ?? this.cycles,
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is Opcode && opcode == other.opcode && addressMode == other.addressMode && bytes == other.bytes && cycles == other.cycles;

  @override
  int get hashCode => opcode.hashCode ^ addressMode.hashCode ^ bytes.hashCode ^ cycles.hashCode;
}
