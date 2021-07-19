INCLUDE "defines.inc"

SECTION "Title Screen Large Star 3 Actor Animation Data", ROMX

xActorLargeStar3Animation::
    animation_def xActorLargeStar3

    cel largeStar3, ANIMATION_DURATION_FOREVER

SECTION "Title Screen Large Star 3 Actor Meta-Sprite Data", ROMX

xActorLargeStar3Metasprites::
    metasprite .largeStar3

.largeStar3
    DB 0, 0, $0A, 0
    DB 0, 8, $0C, 0
    DB 0, 16, $0E, 0
    DB 0, 24, $10, 0
    DB 16, 0, $26, 0
    DB 16, 8, $28, 0
    DB 16, 16, $2A, 0
    DB METASPRITE_END
