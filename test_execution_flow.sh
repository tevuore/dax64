#!/bin/bash
set -e option


echo "---------- SHOW HELP"
dart run bin/dax64.dart --help

echo "---------- SHOW COMMAND HELP"
dart run bin/dax64.dart parsebasicdata -h

echo "---------- CREATE TEMP DIR"
echo "Use /output dir for outputs"
mkdir -p output

echo "---------- PARSE BASIC PROGRAM"
BIN_FILE=output/program.bin
dart run bin/dax64.dart parsebasicdata --input-file programs/program.bas --output-file $BIN_FILE
if [ ! -s "${BIN_FILE}" ]; then
    echo "ERROR: $BIN_FILE file is empty"
    exit 1
fi
echo "$BIN_FILE: $(ls -l $BIN_FILE)"

echo "---------- DISASSEMBLE"
dart run bin/dax64.dart disassemble --input-file output/program.bin --output-file output/program.asm --add-instruction-description
cat output/program.asm

echo "---------- ASSEMBLE"
BIN_FILE=output/program_2.bin
dart run bin/dax64.dart assemble --input-file output/program.asm --output-file $BIN_FILE
if [ ! -s "${BIN_FILE}" ]; then
    echo "ERROR: $BIN_FILE file is empty"
    exit 1
fi
echo "$BIN_FILE: $(ls -l $BIN_FILE)"

echo "---------- GENERATE BASICLOADER"
dart run bin/dax64.dart basicloader --input-file $BIN_FILE --output-file output/program_2.bas
cat output/program_2.bas

echo "---------- DETOKENIZE"
./basicload.sh output/program_2.bas

