INCLUDE "constants/actors.inc"
INCLUDE "macros/actors.inc"

SECTION "Battleship Ship Actor Animation Data", ROMX

xActorShipAnimation::
    animation Ship

SECTION "Battleship Ship Actor Meta-Sprite Data", ROMX

xActorShipMetasprites::
    metasprite .shipCel1
    metasprite .shipCel2

.shipCel1
    obj 32, 8, $00, 0
    obj 16, 8, $02, 0
    obj 1, 16, $04, 0
    obj 32, 32, $12, 0
    obj 16, 32, $14, 0
    obj 1, 24, $16, 0
    obj 32, 4, $06, 0
    obj 16, 8, $08, 0
    obj 1, 16, $0A, 0
    obj 32, 36, $0C, 0
    obj 16, 32, $0E, 0
    obj 1, 24, $10, 0
    DB METASPRITE_END
.shipCel2
    obj 32, 8, $00, 0
    obj 16, 8, $02, 0
    obj 1, 16, $04, 0
    obj 32, 32, $12, 0
    obj 16, 32, $14, 0
    obj 1, 24, $16, 0
    obj 32, 4, $18, 0
    obj 16, 8, $1A, 0
    obj 1, 16, $1C, 0
    obj 32, 36, $1E, 0
    obj 16, 32, $20, 0
    obj 1, 24, $22, 0
    DB METASPRITE_END
