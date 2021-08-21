INCLUDE "constants/hardware.inc"
INCLUDE "constants/actors.inc"
INCLUDE "macros/actors.inc"

SECTION "Battleship Ship Cannon Actor Animation Data", ROMX

xActorShipCannonAnimation::
    animation ShipCannon

SECTION "Battleship Ship Cannon Actor Meta-Sprite Data", ROMX
	
xActorShipCannonMetasprites::
	metasprite .cannonNorth
    metasprite .cannonNorthwest
    metasprite .cannonNortheast

.cannonNorth
    obj 0, 0, $00, 0
    obj 0, 8, $02, 0
    DB METASPRITE_END
.cannonNorthwest
    obj 0, 0, $04, 0
    obj 0, 8, $06, 0
    DB METASPRITE_END
.cannonNortheast
    obj 0, 0, $08, 0
    obj 0, 8, $0A, 0
    DB METASPRITE_END
