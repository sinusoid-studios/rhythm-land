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
