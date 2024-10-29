import 'package:dax64/assembler/assembler_config.dart';
import 'package:dax64/assembler/parser/line_parsers.dart';
import 'package:dax64/models/asm_program.dart';

import '../../models/statement/macro.dart';

// TeroV could be just func
class Parser {
  final AssemblerConfig config;

  Parser({required this.config});

  AsmProgram parse(String input) {
    final program = AsmProgram();

    // currently there is just single block, but in future there could be
    // several separate memory areas
    final block = AsmBlock.withDefaultMemoryAddress();
    program.blocks.add(block);
    var lineNumber = 1;
    // TODO we could have windows line feeds too
    for (final line in input.split('\n')) {
      final assembly = parseNext(lineNumber, line, config);

      // TODO not sure why label can't be null (or Option)
      if (programLine.statement.hasLabel()) {
        program.labels[programLine.statement.label] = programLine;

        if (programLine.statement is MacroAssignment) {
          final assignment = programLine.statement as MacroAssignment;
          program.variables[assignment.name] = assignment;
        } else if (programLine.statement is MacroDefinition) {
          final macro = programLine.statement as MacroDefinition;
          program.macros[macro.name] = macro;
        }
      }
      block.assemblies.add(programLine);
      lineNumber++;
    }

    return program;
  }
}
