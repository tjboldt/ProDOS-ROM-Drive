printChar = $FDED
home = $FC58

  .org $2000

  jsr home
  ldy #$0
nextChar:
  lda text,y
  beq infiniteLoop
  jsr printChar
  iny
  clc
  bcc nextChar
infiniteLoop:
  clc
  bcc infiniteLoop ;hang for eternity

.macro aschi str
.repeat .strlen (str), c
.byte .strat (str, c) | $80
.endrep
.endmacro

text:   
  aschi     "Block 0001 normally reserved for SOS"
  .byte $8D
  aschi     "boot contains the firmware for the"
  .byte $8D
  aschi     "ProDOS ROM-Drive."
  .byte $8D
  .byte $8D
  aschi     "(c)1998 - 2021 Terence J. Boldt"
  .byte $8D
  .byte $8D
  aschi     "github.com/tjboldt/ProDOS-ROMDrive"
  .byte $8D
  .byte $8D
  aschi     "Do NOT overwrite Block 0001"

end:
.byte 0

.repeat	255-<end
.byte 0
.endrepeat
