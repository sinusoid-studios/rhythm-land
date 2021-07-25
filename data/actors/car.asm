INCLUDE "constants/hardware.inc"
INCLUDE "constants/actors.inc"
INCLUDE "macros/actors.inc"

SECTION "Skater Dude Car Actor Animation Data", ROMX

xActorCarAnimation::
    animation Car

.loop
    cel car1, 2
    cel car2, 2
    cel car3, 2
    cel car4, 2
    goto_cel .loop

SECTION "Skater Dude Car Actor Meta-Sprite Data", ROMX

xActorCarMetasprites::
    metasprite .car1
    metasprite .car2
    metasprite .car3
    metasprite .car4

.car1
    DB 1, 0, $9C, OAMF_PAL1
    DB 1, 8, $9E, OAMF_PAL1
    DB 1, 16, $A0, OAMF_PAL1
    DB 1, 24, $A2, OAMF_PAL1
    DB 17, 0, $A4, OAMF_PAL1
    DB 17, 8, $A6, OAMF_PAL1
    DB 17, 16, $A8, OAMF_PAL1
    DB 17, 24, $AA, OAMF_PAL1
    DB METASPRITE_END

.car2
    DB 1, 0, $9C, OAMF_PAL1
    DB 1, 8, $9E, OAMF_PAL1
    DB 1, 16, $A0, OAMF_PAL1
    DB 1, 24, $A2, OAMF_PAL1
    DB 17, 0, $AC, OAMF_PAL1
    DB 17, 8, $A6, OAMF_PAL1
    DB 17, 16, $AE, OAMF_PAL1
    DB 17, 24, $AA, OAMF_PAL1
    DB METASPRITE_END

.car3
    DB 0, 0, $9C, OAMF_PAL1
    DB 0, 8, $9E, OAMF_PAL1
    DB 0, 16, $A0, OAMF_PAL1
    DB 0, 24, $A2, OAMF_PAL1
    DB 16, 0, $B0, OAMF_PAL1
    DB 16, 8, $A6, OAMF_PAL1
    DB 16, 16, $B2, OAMF_PAL1
    DB 16, 24, $B4, OAMF_PAL1
    DB METASPRITE_END

.car4
    DB 0, 0, $9C, OAMF_PAL1
    DB 0, 8, $9E, OAMF_PAL1
    DB 0, 16, $A0, OAMF_PAL1
    DB 0, 24, $A2, OAMF_PAL1
    DB 16, 0, $B6, OAMF_PAL1
    DB 16, 8, $A6, OAMF_PAL1
    DB 16, 16, $B8, OAMF_PAL1
    DB 16, 24, $B4, OAMF_PAL1
    DB METASPRITE_END
