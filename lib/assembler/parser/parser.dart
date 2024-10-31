import 'package:dax64/assembler/assembler_config.dart';
import 'package:dax64/assembler/parser/line_parsers.dart';
import 'package:dax64/models/asm_program.dart';

import '../../models/statement/macro.dart';
import '../errors.dart';

// TeroV could be just func
class Parser {
  final AssemblerConfig config;

  Parser({required this.config});

  AsmProgram parse(String input) {
    final program = AsmProgram();
    // TODO real impl of parsing file; how one file refers to other files?
    //      include statement I guess... but some how refs needs to passed
    //      upwards
    final asmFile = AsmFile(fileName: "main");
    program.files.add(asmFile);

    // currently there is just single block, but in future there could be
    // several separate memory areas
    final block = AsmBlock.withDefaultMemoryAddress();
    asmFile.blocks.add(block);
    var lineNumber = 1;
    // TODO we could have windows line feeds too
    for (final line in input.split('\n')) {
      final sourceLine = SourceLine(lineNumber, line);
      final assembly = parseNext(sourceLine, config);

      for (final key in assembly.defs.keys) {
        final value = assembly.defs[key];

        switch (value) {
          case MacroAssignment _:
            if (program.variables.containsKey(key)) {
              // TBD any chance to get any line number
              throw AssemblerError("Variable '$key' defined twice");
            }
            program.variables[key] = value;
            break;

          case MacroDefinition _:
            if (program.macros.containsKey(key)) {
              // TBD any chance to get any line number
              throw AssemblerError("Macro '$key' defined twice");
            }
            program.macros[key] = value;
            break;

          default:
            // it must be label
            if (program.labels.containsKey(key)) {
              // TBD any chance to get any line number
              throw AssemblerError("Label '$key' defined twice");
            }
            // TeroV does this value has any meanings
            program.labels[key] = assembly.programLines[0];
        }
      }
      block.assemblies.add(assembly);
      lineNumber += assembly.getLineCount();
    }

    return program;
  }
}
