#!/bin/bash

# Taken from https://retrocomputing.stackexchange.com/questions/6051/how-to-transfer-files-to-c64-emulator-quickly

[ ! -f "$1" ] && { echo "usage: $0 filename.txt" ; exit 1; }
tr A-Z a-z < "$1" | petcat -w -2 -o "$1.prg" --
