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
