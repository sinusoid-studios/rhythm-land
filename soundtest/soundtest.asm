
INCLUDE	"constants/hardware.inc"
INCLUDE	"constants/SoundSystem.inc"
INCLUDE	"constants/SoundSystemNotes.inc"

INCLUDE	"data.asm"

;==============================================================
; RST handlers
;==============================================================
RST_38	EQU	$38

SECTION	"RST $38",ROM0[RST_38]
Rst_38::
	ld	b,b	; breakpoint in some emulators
	ret


;==============================================================
; vblank handler
;==============================================================
SECTION	"VBlank Interrupt",ROM0[$40]
VBlankInt::
	push	af
	ld	a,1
	ld	[wVBlankDone],a
	pop	af
	pop	af
	reti


;==============================================================
; cartridge header
;==============================================================
SECTION	"ROM Header",ROM0[$100]
ROMHeader::
	nop
	jp	Start

	DS	$0150 - @, 0


;==============================================================
; starting point
;==============================================================
WaitVRAMAvailable:	MACRO
	ld	hl,rSTAT
.waitvram\@
	bit	1,[hl]	; wait for mode 0 or 1
	jr	nz,.waitvram\@
	ENDM

SECTION	"Start",ROM0[$150]
Start:
	ld	a,BANK(InitializeGB)
	ldh	[hCurrentBank],a

	call	InitializeGB
	call	InitializeVariables

	;--------------------------------------
	call	SoundSystem_Init

	; prepare the sfx
	ld	bc,BANK(SFX_Table)
	ld	de,SFX_Table
	call	SFX_Prepare

	; start the first song playing
	call	ChangeMusic

	;--------------------------------------
mainloop:
	; button processing
	call	ReadJoypad

	; check to see if Start is held down
	ldh	a,[hPressedKeys]
	bit	PADB_START,a
	jr	z,.notoggle

	; channel toggle
	ldh	a,[hNewKeys]
	ld	b,a
	ld	a,AUDTERM_1_LEFT|AUDTERM_1_RIGHT
	bit	PADB_UP,b
	jr	nz,.channeltoggle
	ASSERT AUDTERM_2_LEFT|AUDTERM_2_RIGHT == (AUDTERM_1_LEFT|AUDTERM_1_RIGHT) << 1
	add	a	; shift to channel 2
	bit	PADB_LEFT,b
	jr	nz,.channeltoggle
	ASSERT AUDTERM_3_LEFT|AUDTERM_3_RIGHT == (AUDTERM_2_LEFT|AUDTERM_2_RIGHT) << 1
	add	a	; shift to channel 3
	bit	PADB_RIGHT,b
	jr	nz,.channeltoggle
	ASSERT AUDTERM_4_LEFT|AUDTERM_4_RIGHT == (AUDTERM_3_LEFT|AUDTERM_3_RIGHT) << 1
	add	a	; shift to channel 4
	bit	PADB_DOWN,b
	jr	z,.notoggle

.channeltoggle
	ld	b,a
	; toggle the selected channel's bits in the channel mask
	ld	a,[wChannelMask]
	xor	b
	ld	[wChannelMask],a
	jr	.waitraster

.notoggle
	; check to see if A was pressed
	ldh	a,[hNewKeys]
	ASSERT PADB_A == 0
	rra		; move bit 0 (PADB_A) to carry
	call	c,BtnAPressed
	; check to see if B was pressed
	ldh	a,[hNewKeys]
	bit	PADB_B,a
	call	nz,BtnBPressed
	; check to see if Select was pressed
	ldh	a,[hNewKeys]
	bit	PADB_SELECT,a
	call	nz,BtnSelectPressed
	; check to see if right was pressed
	ldh	a,[hNewKeys]
	bit	PADB_RIGHT,a
	call	nz,BtnRightPressed
	; check to see if left was pressed
	ldh	a,[hNewKeys]
	bit	PADB_LEFT,a
	call	nz,BtnLeftPressed
	; check to see if up was pressed
	ldh	a,[hNewKeys]
	bit	PADB_UP,a
	call	nz,BtnUpPressed
	; check to see if down was pressed
	ldh	a,[hNewKeys]
	ASSERT PADB_DOWN == 7
	add	a	; move bit 7 (PADB_DOWN) to carry
	call	c,BtnDownPressed

	;--------------------------------------
	; audio processing
	; Note: For the sake of this example showing timing,
	; SoundSystem_Process is called at specific time.
	; In normal use, you would call it when appropriate.
.waitraster
	ldh	a,[rLY]
	cp	83
	jr	nz,.waitraster

	; set the bg palette
	WaitVRAMAvailable
	ld	a,$E5
	ldh	[rBGP],a

	call	SoundSystem_Process

	; reset the bg palette
	WaitVRAMAvailable
	ld	a,$E4
	ldh	[rBGP],a

	;--------------------------------------
	call	WaitForVBlankEnd

	; update the ui (i.e. do all the Mode1 tasks first)
	call	DisplaySongTitle
	call	DisplayMusicState
	call	DisplaySync
	call	DisplaySongID
	call	DisplaySFXID
	call	DisplayVUMeters

	; clear the vbl end flag
	xor	a
	ld	[wVBlankDone],a

	; update the frame counter
	ld	hl,wFrameCounter
	inc	[hl]

	jp	mainloop


;==============================================================
; Support Routines (Bank 0)
;==============================================================
; set the coords register (de) for use with PrintString
MakeStringXY:	MACRO
	ld	de,(\1 << 8)|\2
	ENDM

;--------------------------------------------------------------
ChangeMusic:
	call	Music_Pause

	ld	a,[wCurrentSongID]
	add	a	; * 2

	ld	hl,SongDataTable
	add	l
	ld	l,a

	ld	a,[hl+]
	ld	h,[hl]
	ld	l,a

	; put the instrument bank in bc
	ld	a,[hl+]
	ld	c,a
	ld	b,0

	; put the insrument table pointer in de
	ld	a,[hl+]
	ld	e,a
	ld	a,[hl+]
	ld	d,a
	push	hl
	call	Music_PrepareInst
	pop	hl

	; put the imusic bank in bc
	ld	a,[hl+]
	ld	c,a
	ld	b,0

	; put the music table pointer in de
	ld	a,[hl+]
	ld	e,a
	ld	a,[hl+]
	ld	d,a

	call	Music_Play
	ret

;--------------------------------------------------------------
ToggleMusic:
	ld	a,[wMusicPlayState]
	and	MUSIC_STATE_PLAYING
	jr	nz,.pause
	call	Music_Resume
	ret
.pause
	call	Music_Pause
	ret

;--------------------------------------------------------------
TriggerSFX:
	ld	a,[wSFXID]
	ld	b,a
	ld	c,MID_C
	call	SFX_Play
	ret

;--------------------------------------------------------------
DisplaySongTitle:
	ld	h,HIGH(SongTitleTable)
	ld	a,[wSongID]
	add	a	; * 2
	ld	l,a

	ld	a,[hl+]
	ld	b,[hl]
	ld	c,a

	MakeStringXY 0,8
	call	PrintString
	ret

;--------------------------------------------------------------
DisplayMusicState:
	ld	a,[wMusicPlayState]
	and	MUSIC_STATE_PLAYING
	jr	nz,.playing
	ld	bc,StoppedString
	jr	.display
.playing
	ld	bc,PlayingString
.display
	MakeStringXY 6,14
	call	PrintString
	ret

StoppedString:
	DB	"Stop",$00
PlayingString:
	DB	"Play",$00

;--------------------------------------------------------------
DisplaySync:
	ld	h,HIGH(HexTable)
	ld	de,$99E7
	ld	a,[wMusicSyncData]
	ld	b,a

	; left digit
	swap	a
	and	$0F
	ld	l,a
	ld	a,[hl]
	ld	[de],a

	; right digit
	inc	e
	ld	a,b
	and	$0F
	ld	l,a
	ld	a,[hl]
	ld	[de],a
	ret

PUSHS
SECTION	"Hex Table",ROM0,ALIGN[8]
HexTable:
	DB	"0123456789ABCDEF"
POPS

;--------------------------------------------------------------
DisplaySongID:
	ld	a,[wCurrentSongID]
	add	$30
	ld	[$9A07],a
	ret

;--------------------------------------------------------------
DisplaySFXID:
	ld	a,[wSFXID]
	add	$30
	ld	[$9A27],a
	ret

;--------------------------------------------------------------
DisplayVUMeters:
	; channel 1
	; $99EC/$9A0C
	ld	a,[wVUMeter1]
	ld	b,a
	and	$08
	jr	nz,.split1
	; top half
	xor	a
	ld	[$99EC],a
	; bottom half
	ld	a,b
	ld	[$9A0C],a
	jr	.channel2
.split1
	; top half
	ld	a,b
	sub	8
	ld	[$99EC],a
	; bottom half
	ld	a,8
	ld	[$9A0C],a

	; channel 2
	; $99EE/$9A0E
.channel2
	ld	a,[wVUMeter2]
	ld	b,a
	and	$08
	jr	nz,.split2
	; top half
	xor	a
	ld	[$99EE],a
	; bottom half
	ld	a,b
	ld	[$9A0E],a
	jr	.channel3
.split2
	; top half
	ld	a,b
	sub	8
	ld	[$99EE],a
	; bottom half
	ld	a,8
	ld	[$9A0E],a

	; channel 3
	; $99F0/$9A10
.channel3
	ld	a,[wVUMeter3]
	ld	b,a
	and	$08
	jr	nz,.split3
	; top half
	xor	a
	ld	[$99F0],a
	; bottom half
	ld	a,b
	ld	[$9A10],a
	jr	.channel4
.split3
	; top half
	ld	a,b
	sub	8
	ld	[$99F0],a
	; bottom half
	ld	a,8
	ld	[$9A10],a

	; channel 4
	; $99F2/$9A12
.channel4
	ld	a,[wVUMeter4]
	ld	b,a
	and	$08
	jr	nz,.split4
	; top half
	xor	a
	ld	[$99F2],a
	; bottom half
	ld	a,b
	ld	[$9A12],a
	ret
.split4
	; top half
	ld	a,b
	sub	8
	ld	[$99F2],a
	; bottom half
	ld	a,8
	ld	[$9A12],a
	ret

;--------------------------------------------------------------
; wait for the vblank int to set the flag
WaitForVBlankEnd:
.waitloop:
	halt
	ld	a,[wVBlankDone]
	and	1
	jr	z,.waitloop
	ret

;--------------------------------------------------------------
; print a null-terminated string in bc at d,e
; d,e are screen coords in tiles
PrintString:
	; set the y coord
	ld	h,0
	ld	l,e
	add	hl,hl	; * 2
	add	hl,hl	; * 4
	add	hl,hl	; * 8
	add	hl,hl	; * 16
	add	hl,hl	; * 32
	ld	a,$98
	add	h
	ld	h,a

	; set the x coord
	ld	a,l
	add	d
	ld	l,a

	; copy the characters to vram
.charloop
	ld	a,[bc]
	or	a	; is this the NULL terminator?
	ret	z	; yes, exit
	ld	[hl+],a
	inc	bc
	jr	.charloop

;--------------------------------------------------------------
ReadJoypad:
	; read D-Pad
	ld	a,P1F_GET_DPAD
	call	.readNibble
	swap	a	; move directions to high nibble
	ld	b,a

	; read buttons
	ld	a,P1F_GET_BTN
	call	.readNibble
	xor	b	; combine buttons and directions + complement
	ld	b,a

	; update hNewKeys
	ldh	a,[hPressedKeys]
	xor	b	; a = keys that changed state
	and	b	; a = keys that changed to pressed
	ldh	[hNewKeys],a

	ld	a,b
	ldh	[hPressedKeys],a

	; done reading
	ld	a,P1F_GET_NONE
	ldh	[rP1],a
	ret

; @param    a   Value to write to rP1
; @return   a   Reading from rP1, ignoring non-input bits (forced high)
.readNibble
	ldh	[rP1],a
	; burn 16 cycles between write and read
	call	.ret	; 6+4 cycles
	ldh	a,[rP1]	; 3 cycles
	ldh	a,[rP1]	; 3 cycles
	ldh	a,[rP1]	; read
	or	$F0	; ignore non-input bits
.ret
	ret

;==============================================================
; Button press handlers
;==============================================================
BtnAPressed:
	call	ToggleMusic
	ret

BtnBPressed:
	call	TriggerSFX
	ret

BtnSelectPressed:
	ASSERT wSongID == wCurrentSongID + 1	; make sure wSongID follows wCurrentSongID
	ld	hl,wCurrentSongID
	ld	a,[hl+]
	ld	b,a

	ld	a,[hl-]	; get hSongID
	cp	b
	ret	z	; they're the same so there's nothing to do

	; set the current song id
	ld	[hl],a

	call	ChangeMusic
	ret

BtnRightPressed:
	ld	hl,wSongID
	ld	a,[hl]
	inc	a
	cp	NUM_SONGS
	jr	nz,.store
	xor	a
.store
	ld	[hl],a
	ret

BtnLeftPressed:
	ld	hl,wSongID
	ld	a,[hl]
	dec	a
	cp	-1
	jr	nz,.store
	ld	a,NUM_SONGS-1
.store
	ld	[hl],a
	ret

BtnUpPressed:
	ld	hl,wSFXID
	ld	a,[hl]
	inc	a
	cp	NUM_SFX
	jr	nz,.store
	xor	a
.store
	ld	[hl],a
	ret

BtnDownPressed:
	ld	hl,wSFXID
	ld	a,[hl]
	dec	a
	cp	-1
	jr	nz,.store
	ld	a,NUM_SFX-1
.store
	ld	[hl],a
	ret


;==============================================================
; Support Routines (Bank 1)
;==============================================================
; wait for the start of the next V-Blank
WaitVBlankStart:	MACRO
.waitvbl\@
	ldh	a,[rLY]
	cp	SCRN_Y
	jr	nz,.waitvbl\@
	ENDM

SECTION	"Bank 1 Routines",ROMX,BANK[1]
InitializeGB:
	di

	;--------------------------------------
	; turn off the screen after entering a vblank
	WaitVBlankStart

	;--------------------------------------
	; clear LCD control registers and disable audio
	xor	a
	ldh	[rLCDC],a
	ldh	[rIE],a
	ldh	[rIF],a
	ldh	[rSCX],a
	ldh	[rSCY],a
	ldh	[rSTAT],a
	ldh	[rAUDENA],a	; disable the audio

	;--------------------------------------
	; initialize the window posision to 255,255
	dec	a
	ldh	[rWY],a
	ldh	[rWX],a

	;--------------------------------------
	; set the bg palette
	ld	a,$E4
	ldh	[rBGP],a

	;--------------------------------------
	; copy the font tiles to vram
	ld	de,FontTiles			; source
	ld	hl,_VRAM8000			; dest
	ld	bc,(FontTilesEnd - FontTiles)	; num bytes
	call	CopyMem

	;--------------------------------------
	; copy the ui map to vram
	ld	de,UIMap		; source
	ld	hl,_SCRN0		; dest
	ld	bc,(UIMapEnd - UIMap)	; num bytes
	call	CopyMem

	ld	bc,SoundSystem_Version
	ld	de,$00
	call	PrintString

	;--------------------------------------
	; turn on the display
	ld	a,LCDCF_ON|LCDCF_BG8000|LCDCF_BG9800|LCDCF_OBJOFF|LCDCF_BGON
	ldh	[rLCDC],a

	WaitVBlankStart

	;--------------------------------------
	; enable the interrupts
	ld	a,IEF_VBLANK
	ldh	[rIE],a
	xor	a
	ei
	ldh	[rIF],a
	ret

FontTiles:
	INCBIN	"font.bin"
FontTilesEnd:

UIMap:
	DB	"                                "
	DB	"                                "
	DB	"  A  Music Toggle               "
	DB	" ",$EB,"/",$EC," Change Song ID             "
	DB	" Sel Select Song                "
	DB	" ",$E9,"/",$EA," Change SFX ID              "
	DB	"  B  Play SFX                   "
	DB	"                                "
	DB	"                                "
	DB	$DA,"Timing",$D9,$CC,$CC,$CC,$CC,$CC,$CC,$CC,$CC,$CC,$CC,$CC,$DA,"            "
	DB	"                                "
	DB	"                                "
	DB	"                                "
	DB	$DA,"State",$D9,$CC,$CC,$CC,$B7,$DA,"VUM",$D9,$CC,$CC,$CC,$CC,"            "
	DB	"Music:    ",$CD,"                     "
	DB	" Sync:$   ",$CD,"                     "
	DB	" Song:0   ",$CD,"                     "
	DB	"  SFX:0   ",$CD,"                     "
UIMapEnd:

;--------------------------------------------------------------
InitializeVariables:
	ld	hl,wVBlankDone
	xor	a
	ld	[hl+],a	; wVBlankDone
	ld	[hl+],a	; wFrameCounter
	ld	[hl+],a	; wCurrentSongID
	ld	[hl+],a	; wSongID
	ld	[hl+],a	; wSFXID
	ld	[hl+],a	; hPressedKeys
	ld	[hl],a	; hNewKeys
	ret

;--------------------------------------------------------------
; copy bc bytes from de to hl
; no need to wait for STAT, the display is off
CopyMem:
	ld	a,[de]
	ld	[hl+],a
	inc	de
	dec	bc
	ld	a,b
	or	c
	jr	nz,CopyMem
	ret


;==============================================================
; work ram
;==============================================================
SECTION	"Variables",WRAMX
wVBlankDone:	DS	1
wFrameCounter:	DS	1
wCurrentSongID:	DS	1
wSongID:	DS	1
wSFXID:		DS	1

SECTION	"HRAM",HRAM
hPressedKeys:	DS	1
hNewKeys:	DS	1
hCurrentBank::	DS	1
