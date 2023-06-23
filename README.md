README
------

c64 is collection of tools do handle Commodore 64 machine code.

# Running

Example:

    dart run bin/c64.dart commit --file jsons/employee.json

# Building

First you need to generate model classes from json, run
`dart run json_to_model .`

The json_to_model uses flutter foundation package which is not available in plain Dart.
Replace flutter foundation import with meta package.

# Byte handling in Dart

Dart doesn't support 8-bit byte as data type. Instead they need to be handled
as integers. There Uint8List which provides efficient way to store bytes, as it
utilizes 32-bit integers for efficient storage.