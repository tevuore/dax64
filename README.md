README
------

WHAT: c64 is collection of tools do compile & handle Commodore 64 machine code.

STATUS: At the moment it is able to compile simple 6502 assembly code file.

GOAL: This project is a summer project for fun, relearning 6502 assembly and
      diving deeper into Dart programming

c64 can do
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

Install Dart from https://dart.dev/get-dart
or use dvm

xxx


## Install VICE

VICE is a Commodore emulator. It is used to run compiled 6502 machine code using
emulated Commodore 64.

For Ubuntu based: sudo apt install vice.
Other environments: https://vice-emu.sourceforge.io/index.html#download

In addition you need ROM files
* TODO


# Building c64

First you need to generate model classes from json, run
`dart run json_to_model .`

The json_to_model uses flutter foundation package which is not available in plain Dart.
Replace flutter foundation import with meta package in generated files.


# Running tests

Simply execute `dart test` in the root directory of the project.


# Running

Example:

    # Compile 6502 assembly code
    $ dart run bin/c64.dart assemble --input-file program.asm --output-file program.bin

    # Create basic program to load machine code
    $ dart run bin/c64.dart basicloader --input-file program.bin --output-file program.bas

    # Detokenize
    $ ./basicload.sh program.bas

    # Run
    $ x64 -basicload program.bas.prg

There is `run.sh` script which does all the steps above.


# IDE

To easy setup for beginners here are notes of my IDE setup.

Developed with Android Studio Flamingo | 2022.2.1 Patch 1.

Plugins
* Dart

# Byte handling in Dart

Dart doesn't support 8-bit byte as data type. Instead they need to be handled
as integers. There helps Uint8List which provides efficient way to store bytes, as it
utilizes 32-bit integers for efficient storage.


# References

TODO