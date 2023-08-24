import 'package:args/command_runner.dart';
import 'package:dax64/command/assemble_command.dart';
import 'package:dax64/command/basic_loader_command.dart';
import 'package:dax64/command/disassemble_command.dart';
import 'package:dax64/command/parse_basic_data_command.dart';

Future<int> main(List<String> args) async {
  final runner = CommandRunner("dax64", "Commodore 64 machine code utilities")
    ..addCommand(ParseBasicDataCommand())
    ..addCommand(DisassembleCommand())
    ..addCommand(AssembleCommand())
    ..addCommand(BasicLoaderCommand())
    ..argParser.addFlag('verbose', abbr: 'v', help: 'increase logging');

  final result = await runner.run(args);

  if (result is int) return result;
  return 0;
}
