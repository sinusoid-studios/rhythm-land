; Created with Stephane Hockenhull's Game Boy Tracker

; Music Patterns

SECTION "File Select Theme Pattern 0", ROMX

PATTERN_FileSelect0:
    DB $0A
    DB $07, $01, $02, $08, $06, $01, $0E, $01, $07, $08, $06, $01, $02, $13, $0B, $02, $00, $00, $06, $07

SECTION "File Select Theme Pattern 1", ROMX

PATTERN_FileSelect1:
    DB $0A
    DB $07, $0C, $06, $01, $01, $23, $05, $02, $0F, $0C, $01, $0E, $08, $01, $26, $05, $02, $0F, $0B, $02, $01, $0B, $06, $01, $0C, $01, $23, $05, $0B, $02, $01, $0B
    DB $06, $01, $02, $0F, $0C, $01, $0B, $08, $01, $21, $05, $0C, $06, $01, $02, $13, $0C, $01, $1F, $05, $0C, $06, $01, $01, $1C, $05, $02, $0F, $0C, $01, $09, $08
    DB $01, $1A, $05, $02, $0F, $0C, $06, $01, $01, $1C, $05, $0C, $01, $1F, $05, $0C, $01, $04, $08, $06, $01, $01, $21, $05, $02, $0F, $0C, $01, $1F, $05, $0B, $02
    DB $01, $0B, $01, $07, $08, $06, $01, $02, $13, $0B, $02, $00, $0D, $06, $01, $01, $23, $05, $02, $0F, $0C, $01, $0E, $08, $01, $26, $05, $02, $0F, $0B, $02, $01
    DB $0B, $06, $01, $0C, $01, $23, $05, $0B, $02, $01, $0B, $06, $01, $02, $0F, $0C, $01, $0B, $08, $01, $21, $05, $0C, $06, $01, $02, $01, $02, $13, $0C, $01, $1F
    DB $05, $0C, $06, $01, $02, $01, $02, $0F, $0C, $01, $09, $08, $01, $1C, $05, $02, $0F, $0C, $06, $01, $02, $01, $0C, $01, $1C, $05, $02, $0F, $0C, $01, $0B, $08
    DB $06, $01, $01, $1F, $05, $02, $0F, $0E, $01, $07, $08, $06, $01, $02, $01, $02, $13, $0B, $02, $00, $0D, $06, $01, $01, $23, $05, $02, $0F, $0C, $01, $0E, $08
    DB $01, $26, $05, $02, $0F, $0B, $02, $01, $0B, $06, $01, $0C, $01, $23, $05, $0B, $02, $01, $0B, $06, $01, $02, $0F, $0C, $01, $0B, $08, $01, $21, $05, $0C, $06
    DB $01, $02, $13, $0C, $01, $1F, $05, $0C, $06, $01, $01, $1C, $05, $02, $0F, $0C, $01, $09, $08, $01, $1A, $05, $02, $0F, $0C, $06, $01, $01, $1C, $05, $0C, $01
    DB $1F, $05, $0C, $01, $04, $08, $06, $01, $01, $21, $05, $02, $0F, $0C, $01, $1F, $05, $0B, $02, $01, $0B, $01, $07, $08, $06, $01, $01, $23, $05, $02, $13, $0B
    DB $02, $00, $0B, $02, $01, $0C, $06, $01, $01, $2B, $05, $02, $0F, $0B, $02, $01, $0B, $01, $0E, $08, $02, $0F, $0C, $06, $01, $01, $28, $05, $0B, $02, $01, $0D
    DB $06, $01, $01, $26, $05, $02, $0F, $0B, $02, $01, $0B, $01, $0B, $08, $0C, $06, $01, $01, $23, $05, $02, $13, $0C, $01, $22, $05, $0C, $06, $01, $01, $21, $05
    DB $02, $0F, $0C, $01, $0A, $08, $01, $1F, $05, $0C, $06, $01, $02, $01, $02, $0F, $0C, $01, $1A, $05, $0C, $01, $09, $08, $06, $01, $02, $0F, $0C, $02, $0F, $0C
    DB $01, $07, $08, $06, $01, $01, $1F, $05, $02, $13, $0B, $02, $00, $02, $01, $00, $06, $07

SECTION "File Select Theme End Pattern", ROMX

PATTERN_FileSelectLAST:
    DB $08, $F8, $FF, $07

; Music Pattern Order Table

SECTION "File Select Theme Pattern Table", ROMX

Music_FileSelect::
    DW PATTERN_FileSelect0, BANK(PATTERN_FileSelect0)
    DW PATTERN_FileSelect1, BANK(PATTERN_FileSelect1)
    DW PATTERN_FileSelectLAST, BANK(PATTERN_FileSelectLAST)

; Instruments

SECTION "File Select Theme Instruments", ROMX

INSTFileSelect_CHNLOFF: DB $05, $00, $01, $80, $02 
INSTFileSelect1_CHNL1:
    DB $07, $0A, $40
    DB $05, $80, $01, $80
    DB $02
INSTFileSelect2_CHNL0:
    DB $07, $0B, $08
    DB $0A, $80, $05, $A0
    DB $01, $80, $02
INSTFileSelect3_CHNL3:
    DB $07, $0A, $25
    DB $05, $70, $01, $80
    DB $00, $02, $05, $00
    DB $01, $80, $02
INSTFileSelect4_CHNL3:
    DB $07, $0A, $5E
    DB $05, $80, $01, $80
    DB $00, $03, $05, $00
    DB $01, $80, $02

; Instrument Table

Inst_FileSelect::
    DW INSTFileSelect_CHNLOFF
    DW INSTFileSelect1_CHNL1
    DW INSTFileSelect2_CHNL0
    DW INSTFileSelect3_CHNL3
    DW INSTFileSelect4_CHNL3
