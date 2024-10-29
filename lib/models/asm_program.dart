import 'dart:collection';

import 'package:dax64/assembler/parser/parser_state.dart';
import 'package:dax64/models/statement/assembly.dart';
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
  final List<AsmBlock> blocks = [];
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
  final int lineNumber;
  final String originalLine;
  final String? comment;

  // after comment and trimming, real payload of line what is left
  late final String? statementStr;
  final Statement statement;

  AsmProgramLine(
      {required this.lineNumber,
      required this.originalLine,
      required this.statementStr,
      required this.statement,
      this.comment});

  AsmProgramLine.withoutStatement(
      {required this.lineNumber, required this.originalLine, String? comment_})
      : statement = EmptyStatement.empty(),
        comment = comment_ {
    if (comment_ != null) {
      statementStr = originalLine.replaceFirst(comment_, '').trim();
    } else {
      statementStr = originalLine.trim();
    }
  }

  AsmProgramLine.withoutStatementFromState(ParsingState state, {this.comment})
      : lineNumber = state.lineNumber,
        originalLine = state.line,
        statement = EmptyStatement.empty();
}
