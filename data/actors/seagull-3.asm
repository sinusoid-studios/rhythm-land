INCLUDE "defines.inc"

SECTION "Seagull Serenade Seagull 3 Actor Animation Data", ROMX

xActorSeagull3Animation::
    animation_def xActorSeagull3

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
.embarrassed
    INCBIN "res/seagull-serenade/seagull-3/embarrassed.obj.2bpp"
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

.resting1
    DB 0, -1, $10, 0
    DB 0, 7, $12, 0
    DB 0, 15, $14, 0
    DB METASPRITE_END
.resting2
    DB -1, 0, $10, 0
    DB -1, 8, $12, 0
    DB -1, 16, $14, 0
    DB METASPRITE_END
.resting3
    DB 0, 1, $10, 0
    DB 0, 9, $12, 0
    DB 0, 17, $14, 0
    DB METASPRITE_END
.resting4
    DB 0, 0, $10, 0
    DB 0, 8, $12, 0
    DB 0, 16, $14, 0
    DB METASPRITE_END
