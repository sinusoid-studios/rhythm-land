INCLUDE "defines.inc"

SECTION "Skater Dude Actor Animation Data", ROMX

xActorSkaterDudeAnimation::
    DB 0, MUSIC_SKATER_DUDE_SPEED * 4
    DB 1, MUSIC_SKATER_DUDE_SPEED * 4
    DB ANIMATION_GOTO, 0

SECTION "Skater Dude Actor Meta-Sprite Data", ROMX

xActorSkaterDudeMetasprites::
    DW .placeholder0
    DW .placeholder1

.placeholder0
    DB 0, 0, $00, 0
    DB METASPRITE_END

.placeholder1
    DB 0, 0, $02, 0
    DB METASPRITE_END
