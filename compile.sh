#!/bin/bash

filename=$(basename -- "$1")
extension="${filename##*.}"
filename="${filename%.*}"

dart run bin/c64.dart assemble --input-file $1 --output-file $filename.bin
