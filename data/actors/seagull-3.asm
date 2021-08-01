INCLUDE "constants/games/seagull-serenade.inc"
INCLUDE "constants/actors.inc"
INCLUDE "macros/actors.inc"

SECTION "Seagull Serenade Seagull 3 Actor Animation Data", ROMX

xActorSeagull3Animation::
    animation Seagull3

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

xActorSeagull3Tiles:
.resting
    INCBIN "res/seagull-serenade/seagull-3/resting.obj.2bpp"
.missedNote
    INCBIN "res/seagull-serenade/seagull-3/missed-note.obj.2bpp"
.high1
    INCBIN "res/seagull-serenade/seagull-3/high-1.obj.2bpp"
.high2
    INCBIN "res/seagull-serenade/seagull-3/high-2.obj.2bpp"
.mid1
    INCBIN "res/seagull-serenade/seagull-3/mid-1.obj.2bpp"
.mid2
    INCBIN "res/seagull-serenade/seagull-3/mid-2.obj.2bpp"
.low1
    INCBIN "res/seagull-serenade/seagull-3/low-1.obj.2bpp"
.low2
    INCBIN "res/seagull-serenade/seagull-3/low-2.obj.2bpp"

SECTION "Seagull Serenade Seagull 3 Actor Meta-Sprite Data", ROMX

xActorSeagull3Metasprites::
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
    obj 0, -1, $20, 0
    obj 0, 7, $22, 0
    obj 0, 15, $24, 0
    DB METASPRITE_END
.resting2
    obj -1, 0, $20, 0
    obj -1, 8, $22, 0
    obj -1, 16, $24, 0
    DB METASPRITE_END
.resting3
    obj 0, 1, $20, 0
    obj 0, 9, $22, 0
    obj 0, 17, $24, 0
    DB METASPRITE_END
.resting4
    obj 0, 0, $20, 0
    obj 0, 8, $22, 0
    obj 0, 16, $24, 0
    DB METASPRITE_END

.hSquawkCel3
    obj 63, 126, $06, 0
    obj 63, 134, $08, 0
    obj 63, 142, $0A, 0
    DB METASPRITE_END
.hSquawkCel4
    obj 62, 129, $16, 0
    obj 64, 137, $18, 0
    obj 63, 145, $1A, 0
    DB METASPRITE_END

.mSquawkCel3
    obj 64, 123, $0C, 0
    obj 64, 131, $0E, 0
    obj 64, 139, $04, 0
    DB METASPRITE_END
.mSquawkCel4
    obj 64, 125, $1C, 0
    obj 64, 133, $1E, 0
    obj 64, 141, $20, 0
    DB METASPRITE_END

.lSquawkCel3
    obj 67, 122, $10, 0
    obj 65, 130, $12, 0
    obj 64, 137, $14, 0
    DB METASPRITE_END
.lSquawkCel4
    obj 68, 121, $22, 0
    obj 63, 129, $24, 0
    obj 63, 137, $26, 0
    obj 79, 129, $28, 0
    DB METASPRITE_END

.missedNote
    obj 64, 124, $2A, 0
    obj 64, 132, $2C, 0
    obj 64, 140, $2E, 0
    DB METASPRITE_END
