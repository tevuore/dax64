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
