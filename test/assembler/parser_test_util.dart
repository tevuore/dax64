import 'package:dax64/models/asm_program.dart';
import 'package:dax64/models/statement/assembly.dart';
import 'package:test/expect.dart';

AssemblyInstruction extractSingleAssemblyInstruction(AsmProgram program) {
  final lines = program.blocks[0].lines;
  expect(lines.length, equals(1));
  return lines[0].statement as AssemblyInstruction;
}

/// utility function to extract parsed line information
AsmProgramLine takeSingleLineFromSingleBlock(AsmProgram program) {
  expect(program.blocks.length, equals(1));
  expect(program.blocks[0].lines.length, equals(1));
  return program.blocks[0].lines[0];
}

AssemblyInstruction toAssemblyInstruction(AsmProgramLine line) {
  return line.statement as AssemblyInstruction;
}

AssemblyData toAssemblyData(AsmProgramLine line) {
  return line.statement as AssemblyData;
}
