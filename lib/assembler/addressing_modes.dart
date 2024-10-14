// TODO could we have attribute that defines whether operand bytes should be expected?


enum AddressingMode {
  absolute,
  absoluteX,
  absoluteY,
  accumulator,
  immediate,
  implied,
  indirect,
  indirectX,
  indirectY,
  relative,
  zeropage,
  zeropageX,
  zeropageY
}

const addressingModes = {
  'A': AddressingMode.accumulator,
  'abs': AddressingMode.absolute,
  'abs,X': AddressingMode.absoluteX,
  'abs,Y': AddressingMode.absoluteY,
  '#': AddressingMode.immediate,
  'impl': AddressingMode.implied,
  '(ind)': AddressingMode.indirect,
  '(ind,X)': AddressingMode.indirectX,
  '(ind),Y': AddressingMode.indirectY,
  'rel': AddressingMode.relative,
  'zp': AddressingMode.zeropage,
  'zp,X': AddressingMode.zeropageX,
  'zp,Y': AddressingMode.zeropageY,
};

bool areSameAddressingModes(String a, AddressingMode b) {
  switch (a) {
    case 'Accumulator':
      return b == AddressingMode.accumulator;
    case 'Immediate':
      return b == AddressingMode.immediate;
    case 'Implied':
      return b == AddressingMode.implied;
    case '"Bit 0 - Zero Page, Relative':
    case '"Bit 1 - Zero Page, Relative':
    case '"Bit 2 - Zero Page, Relative':
    case '"Bit 3 - Zero Page, Relative':
    case '"Bit 4 - Zero Page, Relative':
    case '"Bit 5 - Zero Page, Relative':
    case '"Bit 6 - Zero Page, Relative':
    case '"Bit 7 - Zero Page, Relative':
      return b == AddressingMode.relative;
    case 'Absolute':
      return b == AddressingMode.absolute;
    case 'Absolute, X':
      return b == AddressingMode.absoluteX;
    case 'Absolute, Y':
      return b == AddressingMode.absoluteY;
    case '(Indirect)':
      return b == AddressingMode.indirect;
    case '(Indirect, X)':
      return b == AddressingMode.indirectX;
    case '(Indirect), Y':
      return b == AddressingMode.indirectY;
    case 'Zero Page':
      return b == AddressingMode.zeropage;
    case 'Zero Page, X':
      return b == AddressingMode.zeropageX;
    case 'Zero Page, Y':
      return b == AddressingMode.zeropageY;
    default:
      throw Exception('Unknown address mode: $a');
  }
}
