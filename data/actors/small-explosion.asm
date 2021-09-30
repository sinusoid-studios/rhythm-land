INCLUDE "constants/hardware.inc"
INCLUDE "constants/actors.inc"
INCLUDE "macros/actors.inc"

SECTION "Battleship Small Explosion Actor Animation Data", ROMX

xActorSmallExplosionAnimation::
    animation SmallExplosion

    cel cel1, 6
    cel cel2, 6
    cel cel3, 6
    cel cel4, 6
    cel cel5, 6
    cel cel6, 6
    DB ANIMATION_KILL_ACTOR

SECTION "Battleship Small Explosion Actor Meta-Sprite Data", ROMX

xActorSmallExplosionMetasprites::
    metasprite .cel1
    metasprite .cel2
    metasprite .cel3
    metasprite .cel4
    metasprite .cel5
    metasprite .cel6

.cel1
    obj 0, 4, $B2, 0
    DB METASPRITE_END
.cel2
    obj 0, 0, $B4, 0
    obj 0, 8, $B6, 0
    DB METASPRITE_END
.cel3
    obj 0, 0, $B8, 0
    obj 0, 8, $BA, 0
    DB METASPRITE_END
.cel4
    obj 0, 0, $BC, 0
    obj 0, 8, $BE, 0
    DB METASPRITE_END
.cel5
    obj 0, 0, $C0, 0
    obj 0, 8, $C2, 0
    DB METASPRITE_END
.cel6
    obj 0, 0, $C4, 0
    obj 0, 8, $C6, 0
    DB METASPRITE_END
