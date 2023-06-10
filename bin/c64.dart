import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:c64/c64.dart' as c64;
import 'package:c64/commit_command.dart';

void main(List<String> args) {
  // print('Hello world: ${c64.calculate()}!');
  //
  // var parser = ArgParser();
  // // TODO how to provide help
  // parser.addOption('mode');
  // parser.addFlag('verbose', defaultsTo: false);
  //
  // var results = parser.parse(args);
  //
  // print(results['mode']); // debug
  // print(results['verbose']); // true

  var runner = CommandRunner("dgit", "A dart implementation of distributed version control.")
    ..addCommand(CommitCommand())
    ..argParser.addFlag('verbose', abbr: 'v', help: 'increase logging')
    ..run(args);

}
