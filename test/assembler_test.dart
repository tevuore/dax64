import 'package:c64/assembler.dart';
import 'package:c64/program_formatter.dart';
import 'package:test/test.dart';

void main() {
  test('should disassemble input', () async {
    // TODO can I have async setup?
    final assembler = Assembler();
    await assembler.initialize();

    final input = r'''
    LDY #$00       ; Load Y
    TYA            ; Transfer Y to Accumulator
    STA $0400,y    ; Store Accumulator
    LDA #$03       ; Load Accumulator
    STA $d800,y    ; Store Accumulator
    INY            ; Increment Y by one
    BNE #$f4       ; Branch if Result Not Zero
    RTS            ; Return from Subroutine
    ''';

    final program = assembler.assemble(input);

    // TODO hex formatter
    final output = ProgramFormatter.format(program, true);
    print(output);
  });
}
