INCLUDE "defines.inc"

SECTION "Skater Dude Oil Barrel Actor Animation Data", ROMX

xActorOilBarrelAnimation::
    animation_def xActorOilBarrel

    cel oilBarrel1, MUSIC_SKATER_DUDE_SPEED / 2
    cel oilBarrel2, MUSIC_SKATER_DUDE_SPEED / 2
    cel oilBarrel3, MUSIC_SKATER_DUDE_SPEED / 2
    cel oilBarrel4, MUSIC_SKATER_DUDE_SPEED / 2
    DB ANIMATION_KILL_ACTOR

SECTION "Skater Dude Oil Barrel Actor Meta-Sprite Data", ROMX

xActorOilBarrelMetasprites::
    metasprite .oilBarrel1
    metasprite .oilBarrel2
    metasprite .oilBarrel3
    metasprite .oilBarrel4

.oilBarrel1
    DB 8, 0, $D8, OAMF_PAL1
    DB 8, 8, $DA, OAMF_PAL1
    DB 8, 16, $DC, OAMF_PAL1
    DB 24, 0, $EA, OAMF_PAL1
    DB 24, 8, $EC, OAMF_PAL1
    DB METASPRITE_END

.oilBarrel2
    DB 8, 0, $DE, OAMF_PAL1
    DB 8, 8, $E0, OAMF_PAL1
    DB 8, 16, $E2, OAMF_PAL1
    DB 24, 0, $EE, OAMF_PAL1
    DB 24, 8, $EC, OAMF_PAL1
    DB METASPRITE_END

.oilBarrel3
    DB 8, 0, $E4, OAMF_PAL1
    DB 8, 8, $E6, OAMF_PAL1
    DB 8, 16, $E2, OAMF_PAL1
    DB 24, 0, $F0, OAMF_PAL1
    DB 24, 8, $EC, OAMF_PAL1
    DB METASPRITE_END

.oilBarrel4
    DB 8, 0, $DE, OAMF_PAL1
    DB 8, 8, $E8, OAMF_PAL1
    DB 8, 16, $DC, OAMF_PAL1
    DB 24, 0, $F2, OAMF_PAL1
    DB 24, 8, $EC, OAMF_PAL1
    DB METASPRITE_END
