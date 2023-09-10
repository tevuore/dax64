import 'package:dax64/basic/basic_parser.dart' as basic_parser;
import 'package:test/test.dart';

void main() {
  test('should parse input', () {
    final input = '''
    1 DATA 10, 20, 30
    2 SKIP THIS LINE
    3 DATA 40, 50, 60, 70
    4 DATA 80, 90
    5 ANOTHER LINE
  ''';
    final expected = [10, 20, 30, 40, 50, 60, 70, 80, 90];

    final parsedValues = basic_parser.parse(input);
    expect(parsedValues.toList(), orderedEquals(expected));
  });
}
