import 'package:dax64/basic/basic_loader.dart';
import 'package:dax64/command/command_base.dart';
import 'package:dax64/command/errors.dart';

class BasicLoaderCommand extends CommandBase {
  @override
  final name = "basicloader";
  @override
  final description = "Wraps bytes into a BASIC loader";

  BasicLoaderCommand() {
    argParser.addOption('input-file');
    argParser.addOption('output-file');
  }

  @override
  void verifyInputs() {
    if (!isInputFileDefined()) {
      throw InvalidInputError("Option 'input-file' is mandatory");
    }
  }

  @override
  Future<int> runCommand() async {
    final bytes = await readInputBytesFile();

    final loader = BasicLoader();
    final output = loader.wrap(bytes);

    if (isOutputFileDefined()) {
      await writeToOutputFile(output);
    } else {
      print(output);
    }

    return 0;
  }
}
