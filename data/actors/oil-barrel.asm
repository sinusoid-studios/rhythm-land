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
