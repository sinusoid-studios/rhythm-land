; Created with Stephane Hockenhull's Game Boy Tracker

SECTION "Sound Effect Data", ROMX

SFX_Table::
    DW 0, 0, SFX1_CHNL2, 0
    DW 0, 0, SFX2_CHNL2, 0
    DW SFX3_CHNL0, 0, 0, 0

SFX1_CHNL2:
    DB $07, $05, $20
    DB $0A, $00, $01, $23
    DB $45, $67, $89, $AB
    DB $CD, $EF, $01, $23
    DB $45, $67, $89, $AB
    DB $CD, $EF, $04, $04
    DB $87, $00, $02, $05
    DB $40, $00, $01, $02
SFX2_CHNL2:
    DB $07, $05, $20
    DB $0A, $01, $01, $23
    DB $45, $67, $89, $AB
    DB $CD, $EF, $FE, $DC
    DB $BA, $98, $76, $54
    DB $32, $10, $04, $C1
    DB $87, $00, $03, $02
SFX3_CHNL0:
    DB $07, $0B, $17
    DB $0A, $00, $05, $F0
    DB $04, $1F, $87, $00
    DB $04, $0B, $08, $04
    DB $90, $87, $00, $14
    DB $0B, $1F, $04, $90
    DB $87, $00, $08, $0B
    DB $1C, $04, $1F, $87
    DB $00, $08, $05, $00
    DB $01, $80, $02
