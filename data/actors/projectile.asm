INCLUDE "constants/hardware.inc"
INCLUDE "constants/actors.inc"
INCLUDE "macros/actors.inc"

SECTION "Battleship Projectile Actor Animation Data", ROMX

xActorProjectileAnimation::
    animation Projectile, PROJECTILE

.left
    cel left, 10
    DB ANIMATION_KILL_ACTOR

    ; Fix alignment
    DS 1
.right
    cel right, 10
    DB ANIMATION_KILL_ACTOR

    ; Cel constant definitions
    def_cel .left, LEFT
    def_cel .right, RIGHT

SECTION "Battleship Projectile Actor Meta-Sprite Data", ROMX

xActorProjectileMetasprites::
    metasprite .left
    metasprite .right

.left
    obj 0, 0, $AE, OAMF_PAL1
    obj 0, 8, $B0, OAMF_PAL1
    DB METASPRITE_END
.right
    obj 0, 0, $B0, OAMF_PAL1 | OAMF_XFLIP
    obj 0, 8, $AE, OAMF_PAL1 | OAMF_XFLIP
    DB METASPRITE_END
