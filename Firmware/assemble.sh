#!/bin/sh 
ca65 Warning.asm -o warning.o
ca65 Firmware.asm -o firmware.o --listing Firmware.lst

ld65 -t none warning.o firmware.o -o Firmware.bin
