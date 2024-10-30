import 'dart:collection';

import 'package:dax64/assembler/assembly.dart';
import 'package:dax64/assembler/errors.dart';
import 'package:dax64/models/statement/empty.dart';
import 'package:dax64/models/statement/macro.dart';
import 'package:dax64/models/statement/statement.dart';
import 'package:meta/meta.dart';

import '../assembler/assembly_context.dart';

/// mutable
class AsmProgram {
  final List<AsmFile> files = [];
  final Map<LabelName, AsmProgramLine> labels = HashMap();
  final Map<VariableName, MacroAssignment> variables = HashMap();
  final Map<MacroName, MacroDefinition> macros = HashMap();
}

/// mutable
class AsmFile {
  final String fileName;
  final List<AsmBlock> blocks = [];

  AsmFile({required this.fileName});
}

/// Asm block is separated by defined target memory address, or unknown
/// memory address for example in cases where file contains just macros
/// or just directly included code.
///
/// mutable
class AsmBlock {
  // -1 means not defined (like in macros or include files)
  // null means it is starting relative address
  final int? memoryAddress;

  // TODO how to put validation of allowed memory address range

  // this list is mutable
  final List<Assembly> assemblies;

  AsmBlock._private(int memoryAddress_, this.assemblies)
      : memoryAddress = memoryAddress_;

  AsmBlock.withUndefinedMemoryAddress()
      : memoryAddress = -1,
        assemblies = [];

  AsmBlock.withDefaultMemoryAddress()
      : memoryAddress = null,
        assemblies = [];

  AsmBlock.withMemoryAddress(int memoryAddress_)
      : memoryAddress = memoryAddress_,
        assemblies = [];

  AsmBlock makeCopy(int memoryAddress) {
    return AsmBlock._private(memoryAddress, assemblies);
  }

  bool hasRelativeAddress() => memoryAddress == null;

  bool hasUndefinedAddress() => memoryAddress == -1;

  bool hasDefinedAddress() => !hasUndefinedAddress();
}

@immutable
class AsmProgramLine {
  final SourceLine line;
  final String? comment;
  final Statement statement;

  AsmProgramLine({required this.line, required this.statement, this.comment});

  factory AsmProgramLine.withoutStatement(
      {required SourceLine line, String? comment}) {
    return AsmProgramLine(
        line: line, statement: EmptyStatement.empty(), comment: comment);
  }

  bool isResolved() => statement.isResolved();
}
