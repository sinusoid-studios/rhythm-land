INCLUDE "defines.inc"

SECTION "Title Screen Large Star 4 Actor Animation Data", ROMX

xActorLargeStar4Animation::
    animation_def xActorLargeStar4

    cel largeStar4, ANIMATION_DURATION_FOREVER

SECTION "Title Screen Large Star 4 Actor Meta-Sprite Data", ROMX

xActorLargeStar4Metasprites::
    metasprite .largeStar4

.largeStar4
    DB 0, 0, $12, 0
    DB 0, 8, $14, 0
    DB 0, 16, $16, 0
    DB 0, 24, $18, 0
    DB 16, 0, $2C, 0
    DB 16, 8, $2E, 0
    DB 16, 16, $30, 0
    DB METASPRITE_END
