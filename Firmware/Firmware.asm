;Please note this code is assembled seven times,
;once for each slot in the Apple II.
;This allows the card to work in any slot without
;having to write space consuming relocatable code.


;Determine which slot we want by command-line define
	if SLOT1
slot    equ     $01
	endif
	if SLOT2
slot    equ     $02
	endif
	if SLOT3
slot    equ     $03
	endif
	if SLOT4
slot    equ     $04
	endif
	if SLOT5
slot    equ     $05
	endif
	if SLOT6
slot    equ     $06
	endif
	if SLOT7
slot    equ     $07
	endif
	
;Calculate I/O addresses for this slot

slotwh  equ     $C081+slot*$10
slotwl  equ     $C080+slot*$10
slotrd  equ     $C080+slot*$10
sdrive  equ     slot*$10

sram0   equ     $478+slot
sram1   equ     $4F8+slot
sram2   equ     $578+slot
sram3   equ     $5F8+slot
sram4   equ     $678+slot
sram5   equ     $6F8+slot
sram6   equ     $778+slot
sram7   equ     $7F8+slot

;ProDOS defines

command equ     $42     ;ProDOS command
unit    equ     $43     ;7=drive 6-4=slot 3-0=not used
buflo   equ     $44     ;low address of buffer
bufhi   equ     $45     ;hi address of buffer
blklo   equ     $46     ;low block
blkhi   equ     $47     ;hi block
ioerr   equ     $27     ;I/O error code
nodev   equ     $28     ;no device connected
wperr   equ     $2B     ;write protect error

	org     $C000+slot*$100
			;code is non-relocatable
			; but duplicated seven times,
			; once for each slot

;ID bytes for booting and drive detection
	cpx     #$20    ;ID bytes for ProDOS and the
	cpx     #$00    ; Apple Autostart ROM
	cpx     #$03    ;
	cpx     #$3C    ;this one for older II's

;display copyright message
	ldy     #$00
drawtxt lda     text,y
	beq     boot    ;check for NULL
	ora     #$80    ;make it visible to the Apple
	sta     $07D0,y ;put text on last line
	iny
	bpl     drawtxt

;load first two blocks and execute to boot
boot    lda     #$01    ;set read command
	sta     command
	lda     #sdrive ;set slot and unit
	sta     unit

	lda     #$00    ;block 0
	sta     blklo
	sta     blkhi
	sta     buflo   ;buffer at $800
	lda     #$08
	sta     bufhi
	jsr     entry   ;get the block

	lda     #$00    ;block 1
	sta     blklo
	sta     blkhi
	sta     buflo   ;buffer at $A00
	lda     #$0A
	sta     bufhi
	jsr     entry   ;get the block

	ldx     #sdrive ;set up for slot n
	jmp     $801    ;execute the block

;This is the ProDOS entry point for this card
entry   lda     #sdrive ;unit number is $n0 - n = slot
	cmp     unit    ;make sure same as ProDOS
	beq     docmd   ;yep, do command
	sec             ;nope, set device not connected
	lda     #nodev
	rts             ;go back to ProDOS

docmd   lda     command ;get ProDOS command
	beq     getstat ;command 0 is GetStatus
	cmp     #$01    ;
	beq     readblk ;command 1 is ReadBlock
	sec             ;Format/Write not permitted
	lda     #wperr  ;write protect error
	rts             ;go back to ProDOS

getstat clc             ;send back status
	lda     #$00    ;good status
	ldx     #$00    ;1024 blocks
	ldy     #$04    ;
	rts

readblk lda     blkhi   ;get hi block
	asl     a       ;shift up to top 3 bits
	asl     a       ;since that's all the high
	asl     a       ;blocks we can handle
	asl     a       ;
	asl     a       ;
	sta     sram0   ;save it in scratch ram 0
			;so we can stuff it in the
			;high latch later
	lda     blklo   ;get low block
	lsr     a       ;shift so we get the top 5
	lsr     a       ;bits - this also goes in
	lsr     a       ;the high latch
	ora     sram0   ;add it to those top 3 bits
	sta     sram0   ;save it back in scratch ram

	lda     blklo   ;get low block
	asl     a       ;shift it to top 3 bits
	asl     a       ;
	asl     a       ;
	asl     a       ;
	asl     a       ;
	sta     sram1   ;save it in scratch ram

	jsr     get256  ;get first half of block

	lda     sram1   ;get low latch
	and     #$F0    ;clear bottom 4 bits
	ora     #$10    ;set bit 5 for second half
			;of 512 byte block
	sta     sram1   ;save it back in scratch

	inc     bufhi   ;write 2nd block up 256 bytes
	jsr     get256  ;get second half of block
	dec     bufhi   ;put ProDOS buffer back

	clc             ;clear error code for success
	lda     #$00
	rts             ;return to ProDOS

;This gets 256 bytes from the ROM card
;assuming high latch value is in sram0
;and low latch value is in sram1
get256  ldy     #$00    ;clear buffer counter
	lda     sram0   ;get high latch value
	sta     slotwh  ;set high latch for card

loop256 ldx     #$00    ;clear port counter
	lda     sram1   ;get low latch value
	sta     slotwl  ;set low latch

loop16  lda     slotrd,x        ;get a byte
	sta     (buflo),y       ;write into the buffer
	iny
	inx
	cpx     #$10
	bne     loop16          ;go until 16 bytes read

	inc     sram1           ;next 16 bytes
	cpy     #$00
	bne     loop256         ;go until 256 total

	rts

text    db      "ROM-Drive (c)1998-2019 Terence J. Boldt", 0

	org     $C0FC+slot*$100
	db      0,0     ;0000 blocks = check status
	db      3       ;bit 0=read 1=status
	db      entry&$00FF ;low byte of entry

