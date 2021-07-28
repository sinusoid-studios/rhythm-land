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
    DB 0, 0, $00, 0
    DB 0, 8, $02, 0
    DB METASPRITE_END
.cannonNorthwest
    DB 0, 0, $04, 0
    DB 0, 8, $06, 0
    DB METASPRITE_END
.cannonNortheast
    DB 0, 0, $08, 0
    DB 0, 8, $0A, 0
    DB METASPRITE_END
