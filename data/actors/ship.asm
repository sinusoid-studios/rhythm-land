INCLUDE "constants/hardware.inc"
INCLUDE "constants/games/battleship.inc"
INCLUDE "constants/actors.inc"
INCLUDE "macros/actors.inc"

SECTION "Battleship Actor Animation Data", ROMX

xActorShipAnimation::
    animation Ship

.loop
    cel forward1, MUSIC_BATTLESHIP_SPEED
    cel forward2, MUSIC_BATTLESHIP_SPEED 
    goto_cel .loop

SECTION "Battleship Ship Actor Meta-Sprite Data", ROMX

xActorShipMetasprites::
    metasprite .forward1
    metasprite .forward2

.forward1
    obj 32, 8, $00, 0
    obj 32, 16, $02, 0
    obj 32, 24, $04, 0
    obj 32, 32, $06, 0
    obj 16, 14, $08, 0
    obj 16, 20, $0A, 0
    obj 16, 26, $0C, 0
    obj 0, 16, $0E, 0
    obj 0, 24, $10, 0
    obj 32, 4, $12, OAMF_PAL1
    obj 32, 36, $14, OAMF_PAL1
    obj 16, 9, $16, OAMF_PAL1
    obj 16, 31, $18, OAMF_PAL1
    obj 0, 16, $1A, OAMF_PAL1
    obj 0, 24, $1C, OAMF_PAL1
    DB METASPRITE_END
.forward2
    obj 32, 8, $00, 0
    obj 32, 16, $02, 0
    obj 32, 24, $04, 0
    obj 32, 32, $06, 0
    obj 16, 14, $08, 0
    obj 16, 20, $0A, 0
    obj 16, 26, $0C, 0
    obj 0, 16, $0E, 0
    obj 0, 24, $10, 0
    obj 32, 4, $1E, OAMF_PAL1
    obj 32, 36, $20, OAMF_PAL1
    obj 16, 9, $22, OAMF_PAL1
    obj 16, 31, $24, OAMF_PAL1
    obj 0, 16, $26, OAMF_PAL1
    obj 0, 24, $28, OAMF_PAL1
    DB METASPRITE_END
