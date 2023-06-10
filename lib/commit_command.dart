import 'package:args/command_runner.dart';

class CommitCommand extends Command {
  // The [name] and [description] properties must be defined by every
  // subclass.
  @override
  final name = "commit";
  @override
  final description = "Record changes to the repository.";

  CommitCommand() {
    // we can add command specific arguments here.
    // [argParser] is automatically created by the parent class.
    argParser.addFlag('all', abbr: 'a', help: "This is help text of 'all'");
  }

  // [run] may also return a Future.
  @override
  void run() {
    // [argResults] is set before [run()] is called and contains the flags/options
    // passed to this command.
    print(argResults!['all']);
  }
}