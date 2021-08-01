INCLUDE "constants/games/seagull-serenade.inc"
INCLUDE "constants/actors.inc"
INCLUDE "macros/actors.inc"

SECTION "Seagull Serenade Seagull 1 Actor Animation Data", ROMX

xActorSeagull1Animation::
    animation Seagull1, SEAGULL

    set_tiles resting, 6
.bobLoop
    cel resting4, 5
    cel resting2, MUSIC_SEAGULL_SERENADE_SPEED * 2 - 5
    goto_cel .bobLoop

.groove
    ; Resting tiles already loaded
.grooveLoop
    cel resting1, MUSIC_SEAGULL_SERENADE_SPEED * 2 - 5
    cel resting2, 5
    cel resting3, MUSIC_SEAGULL_SERENADE_SPEED * 2 - 5
    cel resting2, 5
    goto_cel .grooveLoop

    ; Cel constant definitions
    def_cel .groove, GROOVE

xActorSeagull1Tiles:
.resting
    INCBIN "res/seagull-serenade/seagull-1/resting.obj.2bpp"
.missedNote
    INCBIN "res/seagull-serenade/seagull-1/missed-note.obj.2bpp"
.high1
    INCBIN "res/seagull-serenade/seagull-1/high-1.obj.2bpp"
.high2
    INCBIN "res/seagull-serenade/seagull-1/high-2.obj.2bpp"
.mid1
    INCBIN "res/seagull-serenade/seagull-1/mid-1.obj.2bpp"
.mid2
    INCBIN "res/seagull-serenade/seagull-1/mid-2.obj.2bpp"
.low1
    INCBIN "res/seagull-serenade/seagull-1/low-1.obj.2bpp"
.low2
    INCBIN "res/seagull-serenade/seagull-1/low-2.obj.2bpp"

SECTION "Seagull Serenade Seagull 1 Actor Meta-Sprite Data", ROMX

xActorSeagull1Metasprites::
    metasprite .resting1
    metasprite .resting2
    metasprite .resting3
    metasprite .resting4
    metasprite .hSquawkCel3
    metasprite .hSquawkCel4
    metasprite .mSquawkCel3
    metasprite .mSquawkCel4
    metasprite .lSquawkCel3
    metasprite .lSquawkCel4
    metasprite .missedNote

.resting1
    obj 0, -1, $00, 0
    obj 0, 7, $02, 0
    obj 0, 15, $04, 0
    DB METASPRITE_END
.resting2
    obj -1, 0, $00, 0
    obj -1, 8, $02, 0
    obj -1, 16, $04, 0
    DB METASPRITE_END
.resting3
    obj 0, 1, $00, 0
    obj 0, 9, $02, 0
    obj 0, 17, $04, 0
    DB METASPRITE_END
.resting4
    obj 0, 0, $00, 0
    obj 0, 8, $02, 0
    obj 0, 16, $04, 0
    DB METASPRITE_END

.hSquawkCel3
    obj 0, -3, $06, 0
    obj 0, 5, $08, 0
    obj 0, 13, $0A, 0
    DB METASPRITE_END
.hSquawkCel4
    obj 1, -4, $1A, 0
    obj 1, 4, $1C, 0
    obj -5, 12, $1E, 0
    obj -15, 8, $20, 0
    DB METASPRITE_END

.mSquawkCel3
    obj -1, 1, $0C, 0
    obj -1, 9, $0E, 0
    obj -1, 17, $10, 0
    DB METASPRITE_END
.mSquawkCel4
    obj -2, 1, $22, 0
    obj -2, 9, $24, 0
    obj -2, 17, $26, 0
    DB METASPRITE_END

.lSquawkCel3
    obj 1, 3, $14, 0
    obj 1, 11, $16, 0
    obj 1, 19, $18, 0
    DB METASPRITE_END
.lSquawkCel4
    obj 1, 4, $28, 0
    obj 1, 12, $2A, 0
    obj 4, 20, $2C, 0
    DB METASPRITE_END

.missedNote
    obj 0, 0, $2E, 0
    obj 0, 8, $30, 0
    obj 0, 16, $04, 0
    DB METASPRITE_END
