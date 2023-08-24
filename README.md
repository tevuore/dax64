README
======

WHAT: dax64 is collection of tools disassemble, assemble and support execution of Commodore 64
machine code.

STATUS: At the moment it is able to simple operations for 6502 machine code.

GOAL: This project is a summer project for fun, relearning 6502 assembly and
diving deeper into Dart programming.

dax64 can do

* Extract machine code statements from DATA statements in BASIC programs
* Disassemble machine code to 6502 assembly code
* Assemble 6502 assembly code to machine code
* Create BASIC program to load machine code

Main limitations at the moment

* Can't handle data areas in machine code
* Doesn't support Macro assembler style directives

# Setup

You need

* Dart >= 3.0.0.
* vice
* tr
    - should be available in most Ubuntu based distributions

## Install Dart

Install Dart from https://dart.dev/get-dart****
or use dvm.

## Install VICE

VICE is a Commodore emulator. It is used to run compiled 6502 machine code using
emulated Commodore 64.

For Ubuntu based: sudo apt install vice.
Other environments: https://vice-emu.sourceforge.io/index.html#download

In addition you need ROM files.

* TODO reference to instructions

# Building dax64

First you need to generate model classes from json, run
`dart run json_to_model .`

The json_to_model uses flutter foundation package which is not available in plain Dart.
Replace flutter foundation import with meta package in generated files.

# Running tests

Simply execute `dart test` in the root directory of the project.

# Running

At the moment there is no precompiled binaries available. You need to install Dart SDK.

- Dart 3.0.5 has been currently used for development.

You can either compile with `dart compile` or run directly with `dart run`. Latter is used int this
document.

Example:

```shell
# Show help
$ TODO

# Parse bytes from basic program
$ dart run bin/dax64.dart basicparser --input-file asm_program.bas --output-file program.bin

# Disassemble bytes
$ TODO

# Assemble machine code
$ dart run bin/dax64.dart assemble --input-file program.asm --output-file program.bin

# Create basic program to load machine code
$ dart run bin/dax64.dart basicloader --input-file program.bin --output-file asm_program.bas

# Detokenize 
$ ./basicload.sh asm_program.bas

# Run with VICE
$ x64 -basicload asm_program.bas.prg

```

There is `run.sh` script which does all the steps above.

## Byte handling in Dart

Dart doesn't support 8-bit byte as data type. Instead they need to be handled
as integers. There Uint8List which provides efficient way to store bytes, as it
utilizes 32-bit integers for efficient storage.

