INCLUDE "constants/actors.inc"
INCLUDE "macros/actors.inc"

SECTION "Battleship Explosion Actor Animation Data", ROMX

xActorExplosionAnimation::
    animation Explosion

SECTION "Battleship Explosion Actor Meta-Sprite Data", ROMX

xActorExplosionMetasprites::
    metasprite .explosionCel1
    metasprite .explosionCel2
    metasprite .explosionCel3
    metasprite .explosionCel4
    metasprite .explosionCel5
    metasprite .explosionCel6

.explosionCel1
    obj 0, 0, $00, 0
    obj 0, 8, $02, 0
    DB METASPRITE_END
.explosionCel2
    obj 0, 0, $04, 0
    obj 0, 8, $06, 0
    DB METASPRITE_END
.explosionCel3
    obj 0, 0, $08, 0
    obj 0, 8, $0A, 0
    DB METASPRITE_END
.explosionCel4
    obj 0, 0, $0C, 0
    obj 0, 8, $0E, 0
    DB METASPRITE_END
.explosionCel5
    obj 0, 0, $10, 0
    obj 0, 8, $12, 0
    DB METASPRITE_END
.explosionCel6
    obj 0, 0, $14, 0
    obj 0, 8, $16, 0
    DB METASPRITE_END
