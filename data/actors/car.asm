INCLUDE "defines.inc"

SECTION "Skater Dude Car Actor Animation Data", ROMX

xActorCarAnimation::
    animation_def xActorCar

    cel car1, MUSIC_SKATER_DUDE_SPEED / 2
    cel car2, MUSIC_SKATER_DUDE_SPEED / 2
    cel car3, MUSIC_SKATER_DUDE_SPEED / 2
    cel car4, MUSIC_SKATER_DUDE_SPEED / 2
    DB ANIMATION_KILL_ACTOR

SECTION "Skater Dude Car Actor Meta-Sprite Data", ROMX

xActorCarMetasprites::
    metasprite .car1
    metasprite .car2
    metasprite .car3
    metasprite .car4

.car1
    DB 1, 8, $9C, OAMF_PAL1
    DB 1, 16, $9E, OAMF_PAL1
    DB 1, 24, $A0, OAMF_PAL1
    DB 17, 0, $A2, OAMF_PAL1
    DB 17, 8, $A4, OAMF_PAL1
    DB 17, 16, $A6, OAMF_PAL1
    DB 17, 24, $A8, OAMF_PAL1
    DB METASPRITE_END

.car2
    DB 1, 8, $9C, OAMF_PAL1
    DB 1, 16, $9E, OAMF_PAL1
    DB 1, 24, $A0, OAMF_PAL1
    DB 17, 0, $AA, OAMF_PAL1
    DB 17, 8, $A4, OAMF_PAL1
    DB 17, 16, $AC, OAMF_PAL1
    DB 17, 24, $A8, OAMF_PAL1
    DB METASPRITE_END

.car3
    DB 0, 8, $9C, OAMF_PAL1
    DB 0, 16, $9E, OAMF_PAL1
    DB 0, 24, $A0, OAMF_PAL1
    DB 16, 0, $AE, OAMF_PAL1
    DB 16, 8, $A4, OAMF_PAL1
    DB 16, 16, $B0, OAMF_PAL1
    DB 16, 24, $B2, OAMF_PAL1
    DB METASPRITE_END

.car4
    DB 0, 8, $9C, OAMF_PAL1
    DB 0, 16, $9E, OAMF_PAL1
    DB 0, 24, $A0, OAMF_PAL1
    DB 16, 0, $B4, OAMF_PAL1
    DB 16, 8, $A4, OAMF_PAL1
    DB 16, 16, $B6, OAMF_PAL1
    DB 16, 24, $B2, OAMF_PAL1
    DB METASPRITE_END
