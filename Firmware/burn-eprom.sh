minipro -p "M27C801" -b || { echo "EPROM not blank"; exit 1; }
minipro -p "M27C801" -w GamesWithFirmware.po || { echo "Failed to write EPROM"; exit 1; }
echo Completed writing EPROM
