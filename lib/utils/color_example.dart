import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:console/console.dart';
import 'package:dax64/models/generated/index.dart';
import 'package:dax64/utils/color_text.dart';
import 'package:dax64/utils/colors.dart';

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
    argParser.addOption('file');
    argParser.addFlag('all', abbr: 'a', help: "This is help text of 'all'");
  }

  // [run] may also return a Future.
  @override
  void run() async {
    // [argResults] is set before [run()] is called and contains the flags/options
    // passed to this command.
    print(argResults!['file']);

    Colors.init();
    var colorText = ColorText();
    colorText.setBackgroundColor(7);
    colorText.gold('\n\n\ngold\n').print();

    var pen = TextPen();

    for (var c in Color.getColors().entries) {
      pen.setColor(c.value);
      pen.text('${c.key}\n');
    }
    pen.print();

    final op = await readOpcodeJsonFile('./data/opcodes.json');

    for (var instruction in op.instructions) {
      var colorText = ColorText();
      //colorText.setBackgroundColor(7);
      colorText.gold('\n${instruction.instruction} ');

      for (var opcode in instruction.opcodes) {
        colorText.green('${opcode.opcode} ');
      }
      colorText.print();
    }
  }

  Future<Opcodes> readOpcodeJsonFile(String filePath) async {
    var input = await File(filePath).readAsString();
    var map = jsonDecode(input);
    return Opcodes.fromJson(map);
  }
}
