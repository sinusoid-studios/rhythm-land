INCLUDE "defines.inc"

SECTION "Title Screen Large Star 2 Actor Animation Data", ROMX

xActorLargeStar2Animation::
    animation_def xActorLargeStar2

    cel largeStar2, ANIMATION_DURATION_FOREVER

SECTION "Title Screen Large Star 2 Actor Meta-Sprite Data", ROMX

xActorLargeStar2Metasprites::
    metasprite .largeStar2

.largeStar2
    DB 0, 0, $04, 0
    DB 0, 8, $06, 0
    DB 0, 16, $08, 0
    DB 16, 0, $20, 0
    DB 16, 8, $22, 0
    DB 16, 16, $24, 0
    DB METASPRITE_END
