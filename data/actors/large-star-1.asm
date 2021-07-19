INCLUDE "defines.inc"

SECTION "Title Screen Large Star 1 Actor Animation Data", ROMX

xActorLargeStar1Animation::
    animation_def xActorLargeStar1

    cel largeStar1, ANIMATION_DURATION_FOREVER

SECTION "Title Screen Large Star 1 Actor Meta-Sprite Data", ROMX

xActorLargeStar1Metasprites::
    metasprite .largeStar1

.largeStar1
    DB 0, 0, $00, 0
    DB 0, 8, $02, 0
    DB 16, 0, $1A, 0
    DB 16, 8, $1C, 0
    DB 16, 16, $1E, 0
    DB METASPRITE_END
