#!/bin/bash
set -e option

dart run bin/dax64.dart --help

echo "----------"
dart run bin/dax64.dart parsebasicdata -h

echo "Use /output dir for outputs"
mkdir -p output

echo "----------"
BIN_FILE=output/program.bin
dart run bin/dax64.dart parsebasicdata --input-file programs/program.bas --output-file $BIN_FILE
if [ ! -s "${BIN_FILE}" ]; then
    echo "ERROR: $BIN_FILE file is empty"
    exit 1
fi

echo "----------"
dart run bin/dax64.dart disassemble --input-file output/program.bin --output-file output/program.asm --add-instruction-description
cat output/program.asm

echo "----------"
dart run bin/dax64.dart assemble --input-file output/program.asm --output-file output/program.bin

echo "----------"
dart run bin/dax64.dart basicloader --input-file output/program.bin --output-file output/program_2.bas
cat output/program_2.bas

echo "----------"
./basicload.sh output/program_2.bas

