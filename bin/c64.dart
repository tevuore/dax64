import 'package:args/command_runner.dart';
import 'package:c64/basic_loader_command.dart';
import 'package:c64/command/assemble_command.dart';
import 'package:c64/command/disassemble_command.dart';
import 'package:c64/command/parse_basic_data_command.dart';

Future<int> main(List<String> args) async {
  final runner = CommandRunner("c64", "Commodore 64 machine code utilities")
    ..addCommand(ParseBasicDataCommand())
    ..addCommand(DisassembleCommand())
    ..addCommand(AssembleCommand())
    ..addCommand(BasicLoaderCommand())
    ..argParser.addFlag('verbose', abbr: 'v', help: 'increase logging');

  final result = await runner.run(args);

  if (result is int) return result;
  return 0;
}
