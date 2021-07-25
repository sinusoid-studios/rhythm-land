INCLUDE "constants/hardware.inc"
INCLUDE "constants/actors.inc"
INCLUDE "macros/actors.inc"

SECTION "Skater Dude Log Actor Animation Data", ROMX

xActorLogAnimation::
    animation Log

.loop
    cel log1, 2
    cel log2, 2
    cel log3, 2
    cel log4, 2
    goto_cel .loop

SECTION "Skater Dude Log Actor Meta-Sprite Data", ROMX

xActorLogMetasprites::
    metasprite .log1
    metasprite .log2
    metasprite .log3
    metasprite .log4

.log1
    DB 16, 0, $BA, OAMF_PAL1
    DB 8, 8, $BC, OAMF_PAL1
    DB 8, 16, $BE, OAMF_PAL1
    DB 24, 8, $D2, OAMF_PAL1
    DB METASPRITE_END

.log2
    DB 16, 0, $C0, OAMF_PAL1
    DB 8, 8, $C2, OAMF_PAL1
    DB 8, 16, $C4, OAMF_PAL1
    DB 24, 8, $D4, OAMF_PAL1
    DB METASPRITE_END

.log3
    DB 16, 0, $C6, OAMF_PAL1
    DB 8, 8, $C8, OAMF_PAL1
    DB 8, 16, $CA, OAMF_PAL1
    DB 24, 8, $D6, OAMF_PAL1
    DB METASPRITE_END

.log4
    DB 16, 0, $CC, OAMF_PAL1
    DB 8, 8, $CE, OAMF_PAL1
    DB 8, 16, $D0, OAMF_PAL1
    DB 24, 8, $D8, OAMF_PAL1
    DB METASPRITE_END
