INCLUDE "constants/hardware.inc"
INCLUDE "constants/actors.inc"
INCLUDE "macros/actors.inc"

SECTION "Skater Dude Oil Barrel Actor Animation Data", ROMX

xActorOilBarrelAnimation::
    animation OilBarrel

.loop
    cel oilBarrel1, 2
    cel oilBarrel2, 2
    cel oilBarrel3, 2
    cel oilBarrel4, 2
    goto_cel .loop

SECTION "Skater Dude Oil Barrel Actor Meta-Sprite Data", ROMX

xActorOilBarrelMetasprites::
    metasprite .oilBarrel1
    metasprite .oilBarrel2
    metasprite .oilBarrel3
    metasprite .oilBarrel4

.oilBarrel1
    obj 8, 0, $DA, OAMF_PAL1
    obj 8, 8, $DC, OAMF_PAL1
    obj 8, 16, $DE, OAMF_PAL1
    obj 24, 0, $EC, OAMF_PAL1
    obj 24, 8, $EE, OAMF_PAL1
    DB METASPRITE_END

.oilBarrel2
    obj 8, 0, $E0, OAMF_PAL1
    obj 8, 8, $E2, OAMF_PAL1
    obj 8, 16, $E4, OAMF_PAL1
    obj 24, 0, $F0, OAMF_PAL1
    obj 24, 8, $EE, OAMF_PAL1
    DB METASPRITE_END

.oilBarrel3
    obj 8, 0, $E6, OAMF_PAL1
    obj 8, 8, $E8, OAMF_PAL1
    obj 8, 16, $E4, OAMF_PAL1
    obj 24, 0, $F2, OAMF_PAL1
    obj 24, 8, $EE, OAMF_PAL1
    DB METASPRITE_END

.oilBarrel4
    obj 8, 0, $E0, OAMF_PAL1
    obj 8, 8, $EA, OAMF_PAL1
    obj 8, 16, $DE, OAMF_PAL1
    obj 24, 0, $F4, OAMF_PAL1
    obj 24, 8, $EE, OAMF_PAL1
    DB METASPRITE_END
