#!/bin/sh 
ca65 Warning.asm -o warning.o --listing Warning.lst --list-bytes 255 || exit 1
ca65 Firmware.asm -o firmware.o --listing Firmware.lst --list-bytes 255 || exit 1

ld65 -t none warning.o firmware.o -o Firmware.bin || exit 1

# Firmware.bin must be exactly one ProDOS block: Warning.asm in the low 256
# bytes, Firmware.asm in the upper 256. If the driver outgrows its 256 bytes the
# ".repeat 251-<end" padding in Firmware.asm underflows instead of erroring, so
# check the linked size here before it gets written into any disk image.
SIZE=$(wc -c < Firmware.bin | tr -d ' ')
if [ $SIZE -ne 512 ]; then
	echo "error: Firmware.bin is $SIZE bytes, must be exactly 512" >&2
	exit 1
fi

# assumes ProDOS-Utilities is in your path: https://github.com/tjboldt/ProDOS-Utilities
rm -f BlankDriveWithFirmware.po || exit 1
ProDOS-Utilities -c create -d BlankDriveWithFirmware.po -v ROM -s 2048 || exit 1
ProDOS-Utilities -b 0x0001 -c writeblock -d GamesWithFirmware.po -i Firmware.bin || exit 1
ProDOS-Utilities -b 0x0001 -c writeblock -d BlankDriveWithFirmware.po -i Firmware.bin || exit 1
ProDOS-Utilities -b 0x0001 -c readblock -d BlankDriveWithFirmware.po || exit 1
ProDOS-Utilities -c ls -d BlankDriveWithFirmware.po || exit 1

