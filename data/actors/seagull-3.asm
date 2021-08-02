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
    metasprite .high1
    metasprite .high2
    metasprite .mid1
    metasprite .mid2
    metasprite .low1
    metasprite .low2

.resting1
; Also used for missed note (data happens to be identical)
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

.high1
    obj 1, 1, $00, 0
    obj 1, 9, $02, 0
    obj 1, 17, $04, 0
    DB METASPRITE_END
.high2
    obj -1, 5, $00, 0
    obj 1, 13, $02, 0
    obj 0, 21, $04, 0
    DB METASPRITE_END

.mid1
    obj 0, 0, $00, 0
    obj 0, 8, $02, 0
    obj 0, 16, $04, 0
    DB METASPRITE_END
.mid2
    obj 0, 1, $00, 0
    obj 0, 9, $02, 0
    obj 0, 17, $04, 0
    DB METASPRITE_END

.low1
    obj 3, -3, $00, 0
    obj 1, 5, $02, 0
    obj 0, 12, $04, 0
    DB METASPRITE_END
.low2
    obj 6, -3, $00, 0
    obj 1, 5, $02, 0
    obj 1, 13, $04, 0
    obj 17, 5, $06, 0
    DB METASPRITE_END

.missedNote
    obj 0, -6, $00, 0
    obj 0, 2, $02, 0
    obj 0, 10, $04, 0
    DB METASPRITE_END
