INCLUDE "constants/hardware.inc"
INCLUDE "constants/actors.inc"
INCLUDE "macros/actors.inc"

SECTION "Battleship Ship Cannon Actor Animation Data", ROMX

xActorShipCannonAnimation::
    animation ShipCannon

    cel forward, ANIMATION_DURATION_FOREVER

SECTION "Battleship Ship Cannon Actor Meta-Sprite Data", ROMX

xActorShipCannonMetasprites::
    metasprite .forward
    metasprite .left
    metasprite .right

.forward
    obj 0, 0, $2A, OAMF_PAL1
    obj 0, 8, $2C, OAMF_PAL1
    DB METASPRITE_END
.left
    obj 0, 0, $2E, OAMF_PAL1
    obj 0, 8, $30, OAMF_PAL1
    DB METASPRITE_END
.right
    obj 0, 0, $32, OAMF_PAL1
    obj 0, 8, $34, OAMF_PAL1
    DB METASPRITE_END
