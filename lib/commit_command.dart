import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:c64/models/employee.dart';
import 'package:c64/models/index.dart';
import 'package:c64/utils/color_text.dart';
import 'package:c64/utils/colors.dart';
import 'package:console/console.dart';

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
    colorText
        .gold('\n\n\ngold\n').print();


    var pen = TextPen();

    for (var c in Color.getColors().entries) {
      pen.setColor(c.value);
      pen.text('${c.key}\n');
    }
    pen.print();

    final e = await readJsonFile(argResults!['file']);
    colorText.blue(e.id).print();

    final op = await readOpcodeJsonFile('./opcodes_output.json');


    op.instructions.forEach((instruction) {
      var colorText = ColorText();
      //colorText.setBackgroundColor(7);
      colorText
          .gold('\n${instruction.instruction} ');

      final opcodes = instruction.opcodes;

      instruction.opcodes.forEach((opcode) {
        colorText.green('${opcode.opcode} ');
      });
      colorText.print();
    });

  }

  Future<Employee> readJsonFile(String filePath) async {
    var input = await File(filePath).readAsString();
    var map = jsonDecode(input);
    return Employee.fromJson(map);
  }

  Future<Opcodes> readOpcodeJsonFile(String filePath) async {
    var input = await File(filePath).readAsString();
    var map = jsonDecode(input);
    return Opcodes.fromJson(map);
  }
}