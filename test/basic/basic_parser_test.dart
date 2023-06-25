import 'package:c64/basic/basic_parser.dart' as basic_parser;
import 'package:test/test.dart';

void main() {
  test('should parse input', () {
    String input = '''
    1 DATA 10, 20, 30
    2 SKIP THIS LINE
    3 DATA 40, 50, 60, 70
    4 DATA 80, 90
    5 ANOTHER LINE
  ''';

    final numbers = basic_parser.parse(input);
    print(numbers);
  });
}
