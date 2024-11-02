import 'package:dax64/assembler/assembly.dart';
import 'package:dax64/models/asm_program.dart';
import 'package:test/expect.dart';

// AssemblyInstruction extractSingleAssemblyInstruction(AsmProgram program) {
//   final lines = program.files[0].blocks[0].assemblies[0].programLines;
//   expect(lines.length, equals(1));
//   return lines[0].statement as AssemblyInstruction;
// }

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

ResolvedAssemblyInstruction toResolvedAssemblyInstruction(AsmProgramLine line) {
  switch (line.statement) {
    case ResolvedAssemblyInstruction _:
      return line.statement as ResolvedAssemblyInstruction;

    default:
      throw Exception(
          "AsmProgramLine doesn't have ResolvedAssemblyInstruction: ${line.statement.statementStr}");
  }
}

AssemblyData toAssemblyData(AsmProgramLine line) {
  switch (line.statement) {
    case AssemblyData _:
      return line.statement as AssemblyData;

    default:
      throw Exception(
          "AsmProgramLine doesn't have AssemblyData: ${line.statement.statementStr}");
  }
}
