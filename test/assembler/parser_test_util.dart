import 'package:dax64/assembler/assembly.dart';
import 'package:dax64/models/asm_program.dart';
import 'package:test/expect.dart';

AssemblyInstruction extractSingleAssemblyInstruction(AsmProgram program) {
  final lines = program.files[0].blocks[0].assemblies[0].programLines;
  expect(lines.length, equals(1));
  return lines[0].statement as AssemblyInstruction;
}

/// utility function to extract parsed line information
AsmProgramLine takeSingleLineFromSingleBlock(AsmProgram program) {
  expect(program.files[0].blocks.length, equals(1));
  expect(program.files[0].blocks[0].assemblies.length, equals(1));
  return program.files[0].blocks[0].assemblies[0].programLines[0];
}

List<AsmProgramLine> takeLines(AsmProgram program) {
  expect(program.files[0].blocks.length, equals(1));
  expect(program.files[0].blocks[0].assemblies.length, equals(1));
  return program.files[0].blocks[0].assemblies[0].programLines;
}

AssemblyInstruction toAssemblyInstruction(AsmProgramLine line) {
  return line.statement as AssemblyInstruction;
}

AssemblyData toAssemblyData(AsmProgramLine line) {
  return line.statement as AssemblyData;
}
