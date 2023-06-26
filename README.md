README
------

c64 is collection of tools do handle Commodore 64 machine code.

# Running

Example:

    # Create basic program to load machine code
    $ dart run bin/c64.dart basicloader --input-file program.bin --output-file asm_program.bas
    # Detokenize
    $ ./basicload.sh asm_program.bas
    # Run
    $ x64 -basicload asm_program.bas.prg

# Building

First you need to generate model classes from json, run
`dart run json_to_model .`

The json_to_model uses flutter foundation package which is not available in plain Dart.
Replace flutter foundation import with meta package.

# IDE

To easy setup for beginners here are notes of my IDE setup.

Developed with Android Studio Flamingo | 2022.2.1 Patch 1.

Plugins
* Dart

# Byte handling in Dart

Dart doesn't support 8-bit byte as data type. Instead they need to be handled
as integers. There Uint8List which provides efficient way to store bytes, as it
utilizes 32-bit integers for efficient storage.