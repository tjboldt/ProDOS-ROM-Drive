#!/bin/sh 
ca65 Warning.asm -o warning.o
ca65 Firmware.asm -D SLOT1 -o slot1.o
ca65 Firmware.asm -D SLOT2 -o slot2.o
ca65 Firmware.asm -D SLOT3 -o slot3.o
ca65 Firmware.asm -D SLOT4 -o slot4.o
ca65 Firmware.asm -D SLOT5 -o slot5.o
ca65 Firmware.asm -D SLOT6 -o slot6.o
ca65 Firmware.asm -D SLOT7 -o slot7.o
ld65 -t none warning.o slot1.o slot2.o slot3.o slot4.o slot5.o slot6.o slot7.o -o Firmware.bin
