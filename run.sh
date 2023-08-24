#!/bin/bash

filename=$(basename -- "$1")
extension="${filename##*.}"
filename="${filename%.*}"

dart run bin/dax64.dart assemble --input-file $1 --output-file $filename.bin
dart run bin/dax64.dart basicloader --input-file $filename.bin --output-file $filename.bas
./basicload.sh $filename.bas
x64 -basicload $filename.bas.prg
