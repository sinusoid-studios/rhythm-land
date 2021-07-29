INCLUDE "constants/games/seagull-serenade.inc"
INCLUDE "constants/actors.inc"
INCLUDE "macros/actors.inc"

SECTION "Seagull Serenade Seagull 2 Actor Animation Data", ROMX

xActorSeagull2Animation::
    animation Seagull2

    set_tiles resting, 6
.bobLoop
    cel resting4, 5
    cel resting2, MUSIC_SEAGULL_SERENADE_SPEED * 2 - 5
    goto_cel .bobLoop

    ; Resting tiles already loaded
.grooveLoop
    cel resting1, MUSIC_SEAGULL_SERENADE_SPEED * 2 - 5
    cel resting2, 5
    cel resting3, MUSIC_SEAGULL_SERENADE_SPEED * 2 - 5
    cel resting2, 5
    goto_cel .grooveLoop

xActorSeagull2Tiles:
.resting
    INCBIN "res/seagull-serenade/seagull-2/resting.obj.2bpp"
.angry
    INCBIN "res/seagull-serenade/seagull-2/angry.obj.2bpp"
.high1
    INCBIN "res/seagull-serenade/seagull-2/high-1.obj.2bpp"
.high2
    INCBIN "res/seagull-serenade/seagull-2/high-2.obj.2bpp"
.mid1
    INCBIN "res/seagull-serenade/seagull-2/mid-1.obj.2bpp"
.mid2
    INCBIN "res/seagull-serenade/seagull-2/mid-2.obj.2bpp"
.low1
    INCBIN "res/seagull-serenade/seagull-2/low-1.obj.2bpp"
.low2
    INCBIN "res/seagull-serenade/seagull-2/low-2.obj.2bpp"

SECTION "Seagull Serenade Seagull 2 Actor Meta-Sprite Data", ROMX

xActorSeagull2Metasprites::
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
    obj 0, -1, $10, 0
    obj 0, 7, $12, 0
    obj 0, 15, $14, 0
    DB METASPRITE_END
.resting2
    obj -1, 0, $10, 0
    obj -1, 8, $12, 0
    obj -1, 16, $14, 0
    DB METASPRITE_END
.resting3
    obj 0, 1, $10, 0
    obj 0, 9, $12, 0
    obj 0, 17, $14, 0
    DB METASPRITE_END
.resting4
    obj 0, 0, $10, 0
    obj 0, 8, $12, 0
    obj 0, 16, $14, 0
    DB METASPRITE_END

.hSquawkCel3
    obj 8, 8, $06, 0
    obj 8, 16, $08, 0
    obj 8, 24, $0A, 0
    DB METASPRITE_END
.hSquawkCel4
    obj 7, 8, $1A, 0
    obj 8, 16, $1C, 0
    obj 5, 24, $1E, 0
    DB METASPRITE_END

.mSquawkCel3
    obj 8, 8, $00, 0
    obj 8, 16, $0C, 0
    obj 8, 24, $0E, 0
    DB METASPRITE_END
.mSquawkCel4
    obj 8, 8, $20, 0
    obj 8, 16, $22, 0
    obj 9, 24, $24, 0
    DB METASPRITE_END

.lSquawkCel3
    obj 8, 8, $12, 0
    obj 8, 16, $14, 0
    obj 24, 17, $16, 0
    obj 11, 24, $18, 0
    DB METASPRITE_END
.lSquawkCel4
    obj 8, 8, $26, 0
    obj 8, 16, $28, 0
    obj 15, 23, $2A, 0
    obj 12, 19, $2C, 0
    DB METASPRITE_END

.missedNote
    obj 8, 8, $2E, 0
    obj 8, 16, $30, 0
    obj 8, 24, $04, 0
    DB METASPRITE_END
