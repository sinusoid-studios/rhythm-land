; Created with Stephane Hockenhull's Game Boy Tracker

; Music Patterns

SECTION "Bad Theme Pattern 0", ROMX

PATTERN_Bad0:
    DB $0A
    DB $09, $04, $31, $04, $82, $01, $0E, $0A, $0E, $01, $13, $0A, $02, $13, $0B, $02, $02, $00, $08, $07

SECTION "Bad Theme Pattern 1", ROMX

PATTERN_Bad1:
    DB $0A
    DB $09, $0C, $01, $23, $05, $02, $0F, $0C, $01, $26, $05, $01, $1A, $0A, $02, $0F, $0B, $02, $01, $0D, $01, $23, $05, $0B, $02, $01, $0B, $02, $0F, $0C, $01, $21
    DB $05, $01, $17, $0A, $0C, $02, $13, $0C, $01, $1F, $05, $0C, $01, $1C, $05, $02, $0F, $0C, $01, $1A, $05, $01, $15, $0A, $02, $0F, $0C, $01, $1C, $05, $0C, $01
    DB $1F, $05, $0C, $01, $21, $05, $01, $10, $0A, $02, $0F, $0C, $01, $1F, $05, $0B, $02, $01, $0B, $01, $13, $0A, $02, $13, $0B, $02, $02, $0D, $01, $23, $05, $02
    DB $0F, $0C, $01, $26, $05, $01, $1A, $0A, $02, $0F, $0B, $02, $01, $0D, $01, $23, $05, $0B, $02, $01, $0B, $02, $0F, $0C, $01, $21, $05, $01, $17, $0A, $0C, $02
    DB $01, $02, $13, $0C, $01, $1F, $05, $0C, $02, $01, $02, $0F, $0C, $01, $1C, $05, $01, $15, $0A, $02, $0F, $0C, $02, $01, $0C, $01, $1C, $05, $02, $0F, $0C, $01
    DB $1F, $05, $01, $17, $0A, $02, $0F, $0E, $02, $01, $01, $13, $0A, $02, $13, $0B, $02, $02, $0D, $01, $23, $05, $02, $0F, $0C, $01, $26, $05, $01, $1A, $0A, $02
    DB $0F, $0B, $02, $01, $0D, $01, $23, $05, $0B, $02, $01, $0B, $02, $0F, $0C, $01, $21, $05, $01, $17, $0A, $0C, $02, $13, $0C, $01, $1F, $05, $0C, $01, $1C, $05
    DB $02, $0F, $0C, $01, $1A, $05, $01, $15, $0A, $02, $0F, $0C, $01, $1C, $05, $0C, $01, $1F, $05, $0C, $01, $21, $05, $01, $10, $0A, $02, $0F, $0C, $01, $1F, $05
    DB $0B, $02, $01, $0B, $01, $23, $05, $01, $13, $0A, $02, $13, $0B, $02, $02, $0B, $02, $01, $0C, $01, $2B, $05, $02, $0F, $0B, $02, $01, $0B, $01, $1A, $0A, $02
    DB $0F, $0C, $01, $28, $05, $0B, $02, $01, $0D, $01, $26, $05, $02, $0F, $0B, $02, $01, $0B, $01, $17, $0A, $0C, $01, $23, $05, $02, $13, $0C, $01, $22, $05, $0C
    DB $01, $21, $05, $02, $0F, $0C, $01, $1F, $05, $01, $16, $0A, $0C, $02, $01, $02, $0F, $0C, $01, $1A, $05, $0C, $04, $71, $01, $15, $0A, $02, $0F, $0C, $02, $0F
    DB $0C, $04, $31, $01, $1F, $05, $01, $13, $0A, $02, $13, $0B, $02, $01, $02, $02, $00, $08, $07

SECTION "Bad Theme End Pattern", ROMX

PATTERN_BadLAST:
    DB $08, $F8, $FF, $07

; Music Pattern Order Table

SECTION "Bad Theme Pattern Table", ROMX

Music_Bad::
    DW PATTERN_Bad0, BANK(PATTERN_Bad0)
    DW PATTERN_Bad1, BANK(PATTERN_Bad1)
    DW PATTERN_BadLAST, BANK(PATTERN_BadLAST)

; Instruments

SECTION "Bad Theme Instruments", ROMX

INSTBad_CHNLOFF: DB $05, $00, $01, $80, $02
INSTBad1_CHNL1:
    DB $07, $0A, $80
    DB $05, $C0, $01, $80
    DB $00, $01, $0A, $40
    DB $05, $A0, $01, $80
    DB $02
INSTBad2_CHNL2:
    DB $07, $05, $20
    DB $0A, $00, $00, $11
    DB $22, $33, $44, $56
    DB $78, $76, $79, $CE
    DB $FF, $FD, $80, $24
    DB $54, $21, $01, $80
    DB $00, $50, $02
INSTBad3_CHNL3:
    DB $07, $0A, $25
    DB $05, $91, $01, $80
    DB $02
INSTBad4_CHNL3:
    DB $07, $0A, $5E
    DB $05, $A1, $01, $80
    DB $02

; Instrument Table

Inst_Bad::
    DW INSTBad_CHNLOFF
    DW INSTBad1_CHNL1
    DW INSTBad2_CHNL2
    DW INSTBad3_CHNL3
    DW INSTBad4_CHNL3
