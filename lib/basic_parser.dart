
import 'dart:typed_data';

Uint8List parse(String input) {
  final allNumbers = BytesBuilder();

  // Split the input into lines
  List<String> lines = input.split('\n');

  // Iterate over each line
  for (String line in lines) {
    // Trim leading and trailing whitespaces
    line = line.trim();

    // Check if the line starts with a number followed by a space
    if (line.isNotEmpty && line.contains(' ') && int.tryParse(line[0]) != null) {
      // Split the line by space
      List<String> lineParts = line.split(' ');

      // Check if the line continues with the word "DATA"
      if (lineParts.length > 1 && lineParts[1] == 'DATA') {
        // Get the list of numbers after "DATA" and split by ','
        List<String> numberStrings = lineParts.sublist(2).join(' ').split(',');

        // Iterate over each number string and parse it as an integer
        for (String numberString in numberStrings) {
          int? number = int.tryParse(numberString.trim());
          if (number != null && number >= 0 && number <= 255) {
            allNumbers.addByte(number);
          }
        }
      }
    }
  }

  return UnmodifiableUint8ListView(allNumbers.takeBytes());
}
