INCLUDE "constants/hardware.inc"
INCLUDE "constants/actors.inc"
INCLUDE "macros/actors.inc"

SECTION "Skater Dude Obstacle Actors Animation Data", ROMX

xActorObstacleAnimation::
    animation Obstacle

    ; All obstacles have an animation like this
    ; (4 cels, looping, 2 frames each)
.loop
    DB 0, 2
    DB 1, 2
    DB 2, 2
    DB 3, 2
    goto_cel .loop

SECTION "Skater Dude Car Actor Meta-Sprite Data", ROMX

xActorCarMetasprites::
    DW .car1
    DW .car2
    DW .car3
    DW .car4

.car1
    obj 1, 0, $9C, OAMF_PAL1
    obj 1, 8, $9E, OAMF_PAL1
    obj 1, 16, $A0, OAMF_PAL1
    obj 1, 24, $A2, OAMF_PAL1
    obj 17, 0, $A4, OAMF_PAL1
    obj 17, 8, $A6, OAMF_PAL1
    obj 17, 16, $A8, OAMF_PAL1
    obj 17, 24, $AA, OAMF_PAL1
    DB METASPRITE_END

.car2
    obj 1, 0, $9C, OAMF_PAL1
    obj 1, 8, $9E, OAMF_PAL1
    obj 1, 16, $A0, OAMF_PAL1
    obj 1, 24, $A2, OAMF_PAL1
    obj 17, 0, $AC, OAMF_PAL1
    obj 17, 8, $A6, OAMF_PAL1
    obj 17, 16, $AE, OAMF_PAL1
    obj 17, 24, $AA, OAMF_PAL1
    DB METASPRITE_END

.car3
    obj 0, 0, $9C, OAMF_PAL1
    obj 0, 8, $9E, OAMF_PAL1
    obj 0, 16, $A0, OAMF_PAL1
    obj 0, 24, $A2, OAMF_PAL1
    obj 16, 0, $B0, OAMF_PAL1
    obj 16, 8, $A6, OAMF_PAL1
    obj 16, 16, $B2, OAMF_PAL1
    obj 16, 24, $B4, OAMF_PAL1
    DB METASPRITE_END

.car4
    obj 0, 0, $9C, OAMF_PAL1
    obj 0, 8, $9E, OAMF_PAL1
    obj 0, 16, $A0, OAMF_PAL1
    obj 0, 24, $A2, OAMF_PAL1
    obj 16, 0, $B6, OAMF_PAL1
    obj 16, 8, $A6, OAMF_PAL1
    obj 16, 16, $B8, OAMF_PAL1
    obj 16, 24, $B4, OAMF_PAL1
    DB METASPRITE_END

SECTION "Skater Dude Log Actor Meta-Sprite Data", ROMX

xActorLogMetasprites::
    DW .log1
    DW .log2
    DW .log3
    DW .log4

.log1
    obj 16, 8, $BA, OAMF_PAL1
    obj 8, 16, $BC, OAMF_PAL1
    obj 8, 24, $BE, OAMF_PAL1
    obj 24, 16, $D2, OAMF_PAL1
    DB METASPRITE_END

.log2
    obj 16, 8, $C0, OAMF_PAL1
    obj 8, 16, $C2, OAMF_PAL1
    obj 8, 24, $C4, OAMF_PAL1
    obj 24, 16, $D4, OAMF_PAL1
    DB METASPRITE_END

.log3
    obj 16, 8, $C6, OAMF_PAL1
    obj 8, 16, $C8, OAMF_PAL1
    obj 8, 24, $CA, OAMF_PAL1
    obj 24, 16, $D6, OAMF_PAL1
    DB METASPRITE_END

.log4
    obj 16, 8, $CC, OAMF_PAL1
    obj 8, 16, $CE, OAMF_PAL1
    obj 8, 24, $D0, OAMF_PAL1
    obj 24, 16, $D8, OAMF_PAL1
    DB METASPRITE_END

SECTION "Skater Dude Oil Barrel Actor Meta-Sprite Data", ROMX

xActorOilBarrelMetasprites::
    DW .oilBarrel1
    DW .oilBarrel2
    DW .oilBarrel3
    DW .oilBarrel4

.oilBarrel1
    obj 8, 8, $DA, OAMF_PAL1
    obj 8, 16, $DC, OAMF_PAL1
    obj 8, 24, $DE, OAMF_PAL1
    obj 24, 8, $EC, OAMF_PAL1
    obj 24, 16, $EE, OAMF_PAL1
    DB METASPRITE_END

.oilBarrel2
    obj 8, 8, $E0, OAMF_PAL1
    obj 8, 16, $E2, OAMF_PAL1
    obj 8, 24, $E4, OAMF_PAL1
    obj 24, 8, $F0, OAMF_PAL1
    obj 24, 16, $EE, OAMF_PAL1
    DB METASPRITE_END

.oilBarrel3
    obj 8, 8, $E6, OAMF_PAL1
    obj 8, 16, $E8, OAMF_PAL1
    obj 8, 24, $E4, OAMF_PAL1
    obj 24, 8, $F2, OAMF_PAL1
    obj 24, 16, $EE, OAMF_PAL1
    DB METASPRITE_END

.oilBarrel4
    obj 8, 8, $E0, OAMF_PAL1
    obj 8, 16, $EA, OAMF_PAL1
    obj 8, 24, $DE, OAMF_PAL1
    obj 24, 8, $F4, OAMF_PAL1
    obj 24, 16, $EE, OAMF_PAL1
    DB METASPRITE_END
