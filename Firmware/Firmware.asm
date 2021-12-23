;i/o ports to write to
  writeLatchHigh = $C081
  writeLatchLow = $C080

;temp variables becasue 6502 only has 3 registers
	highLatch = $F8
	lowLatch = $F9
	tempY = $FE
	blockHalfCounter = $FF   

;ProDOS defines
  command = $42   ;ProDOS command
  unit  = $43  ;7=drive 6-4=slot 3-0=not used
  buflo = $44  ;low address of buffer
  bufhi = $45  ;hi address of buffer
  blklo = $46  ;low block
  blkhi = $47  ;hi block
  ioerr = $27  ;I/O error code
  nodev = $28  ;no device connected
  wperr = $2B  ;write protect error

;for relocatable code, address to jump to instead of JSR absolute + RTS
	jumpAddressLo = $FA
	jumpAddressHi = $FB 
	ioAddressLo   = $FC
	ioAddressHi   = $FD
	knownRts   = $FF58

	.org  $C700
  ;code is relocatable
  ; but set to $c700 for
  ; readability

;ID bytes for booting and drive detection
	cpx  #$20    ;ID bytes for ProDOS and the
	ldy  #$00    ; Apple Autostart ROM
	cpx  #$03    ;
	cpx  #$3C    ;this one for older II's

;zero out block numbers and buffer address
	sty	 buflo
	sty  blklo
	sty  blkhi
	iny				;set command = 1 for read block
	sty  command 
	sty  jumpAddressLo ;$01 of $0801 where boot code starts
	jsr  knownRts ;jump to known RTS to get our address from the stack
	tsx
  lda  $0100,x ;this for example would be $C7 in slot 7
  sta  bufhi   ;keep the slot here
  asl   
  asl   
  asl   
  asl   
  tax			

;display copyright message
  ldy  #<text
drawtxt:
  lda  (buflo),y
	sta  $07D0-<text,y ;put text on last line
	iny
	bne  drawtxt

;load block 0000 at $0800
	lda  #$08
	sta  bufhi
	sta  jumpAddressHi
	stx  unit
	bne  start
;This is the ProDOS entry point for this card
entry:
	lda  #<knownRts
	sta  jumpAddressLo
	lda  #>knownRts
	sta  jumpAddressHi
start:
	lda  #$C0
	sta  ioAddressHi
	jsr  knownRts
	tsx
	lda  $0100,x
	asl  a
	asl  a
	asl  a
	asl  a
	tax
	cpx  unit	 ;make sure same as ProDOS
	beq  docmd ;yep, do command
	sec				 ;nope, set device not connected
	lda  #nodev
	rts        ;go back to ProDOS

docmd:
	lda  command
	beq  getstat ;command 0 is GetStatus
	cmp  #$01
	beq  readblk ;command 1 is ReadBlock
	sec          ;Format/Write not permitted
	lda  #wperr  ;write protect error
	rts          ;go back to ProDOS

getstat:  
	clc       ;send back status
	lda  #$00 ;good status
	ldx  #$00 ;1024 blocks
	ldy  #$04 ;
	rts

readblk:
	lda  blkhi	;get hi block
	asl  a    ;shift up to top 3 bits
	asl  a    ;since that's all the high
	asl  a    ;blocks we can handle
	asl  a    ;
	asl  a    ;
	sta  highLatch   ;save it in scratch ram 0
			;so we can stuff it in the
			;high latch later
	lda  blklo   ;get low block
	lsr  a    ;shift so we get the top 5
	lsr  a    ;bits - this also goes in
	lsr  a    ;the high latch
	ora  highLatch ;add it to those top 3 bits
	sta  highLatch ;save it back in scratch ram
	lda  blklo   ;get low block
	asl  a    ;shift it to top 3 bits
	asl  a    ;
	asl  a    ;
	asl  a    ;
	asl  a    ;
	sta  lowLatch
	lda  #$02
	sta  blockHalfCounter

;This gets 256 bytes from the ROM card

read256:
	ldy  #$00
	lda  highLatch	;get high latch value
	sta  writeLatchHigh,x	;set high latch for card
loop256:
	lda  lowLatch
	sta  writeLatchLow,x
	txa
	ora  #$80
	sta  ioAddressLo
loop16:
	sty  tempY
	ldy  #$00
	lda  (ioAddressLo),y
	ldy  tempY
	sta  (buflo),y
	iny
	inc  ioAddressLo
	lda  ioAddressLo
	and  #$0F
	bne  loop16
	inc  lowLatch
	cpy  #$00
	bne  loop256
	dec  blockHalfCounter
	bne  readnext256
	dec  bufhi
	clc       ;clear error code for success
	lda  #$00
	jmp  (jumpAddressLo)

readnext256:  
	inc  bufhi
  clc
  bcc  read256

;macro for string with high-bit set
.macro aschi str
.repeat .strlen (str), c
.byte .strat (str, c) | $80
.endrep
.endmacro

text:   aschi   "ROM-Drive (c)1998-2021 Terence J. Boldt"
end:
.byte	 0

; These bytes need to be at the top of the 256 byte firmware as ProDOS
; uses these to find the entry point and drive capabilities

.repeat	251-<end
.byte 0
.endrepeat

.byte   0,0  ;0000 blocks = check status
.byte   3    ;bit 0=read 1=status
.byte  <entry ;low byte of entry
