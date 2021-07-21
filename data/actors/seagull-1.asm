INCLUDE "constants/games/seagull-serenade.inc"
INCLUDE "constants/actors.inc"
INCLUDE "macros/actors.inc"

SECTION "Seagull Serenade Seagull 1 Actor Animation Data", ROMX

xActorSeagull1Animation::
    animation_def xActorSeagull1, SEAGULL

    set_tiles resting, 6
.bobLoop
    cel resting4, 5
    cel resting2, MUSIC_SEAGULL_SERENADE_SPEED * 2 - 5
    goto_cel .bobLoop

    cel_def GROOVE
    ; Resting tiles already loaded
.grooveLoop
    cel resting1, MUSIC_SEAGULL_SERENADE_SPEED * 2 - 5
    cel resting2, 5
    cel resting3, MUSIC_SEAGULL_SERENADE_SPEED * 2 - 5
    cel resting2, 5
    goto_cel .grooveLoop

xActorSeagull1Tiles:
.resting
    INCBIN "res/seagull-serenade/seagull-1/resting.obj.2bpp"
.angry
    INCBIN "res/seagull-serenade/seagull-1/angry.obj.2bpp"
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

.resting1
    DB 0, -1, $00, 0
    DB 0, 7, $02, 0
    DB 0, 15, $04, 0
    DB METASPRITE_END
.resting2
    DB -1, 0, $00, 0
    DB -1, 8, $02, 0
    DB -1, 16, $04, 0
    DB METASPRITE_END
.resting3
    DB 0, 1, $00, 0
    DB 0, 9, $02, 0
    DB 0, 17, $04, 0
    DB METASPRITE_END
.resting4
    DB 0, 0, $00, 0
    DB 0, 8, $02, 0
    DB 0, 16, $04, 0
    DB METASPRITE_END
