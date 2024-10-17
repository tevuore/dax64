import 'package:dax64/assembler/assembler_config.dart';
import 'package:dax64/assembler/parser/line_parsers.dart';
import 'package:dax64/models/asm_program.dart';

class Parser {
  final AssemblerConfig config;

  Parser({required this.config});

  AsmProgram parse(String input) {
    final program = AsmProgram();

    // currently there is just single block, but in future there could be
    // several separate memory areas
    final block = AsmBlock();
    program.blocks.add(block);
    var lineNumber = 1;
    for (final line in input.split('\n')) {
      var programLine = parseLine(lineNumber, line);
      block.lines.add(programLine);
      lineNumber++;
    }

    return program;
  }

  AsmProgramLine parseLine(final int lineNumber, final String unmodifiedLine) {
    return parseAsmProgramLine(lineNumber, unmodifiedLine, config);
  }
}
