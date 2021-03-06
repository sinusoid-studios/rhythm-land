INCLUDE "constants/hardware.inc"
INCLUDE "constants/games/skater-dude.inc"
INCLUDE "constants/actors.inc"
INCLUDE "macros/actors.inc"

SECTION "Skater Dude Danger Alert Actor Animation Data", ROMX

xActorDangerAlertAnimation::
    animation DangerAlert

    cel visible, MUSIC_SKATER_DUDE_SPEED
    cel hidden, MUSIC_SKATER_DUDE_SPEED
    cel visible, MUSIC_SKATER_DUDE_SPEED
    cel hidden, MUSIC_SKATER_DUDE_SPEED
    DB ANIMATION_KILL_ACTOR

SECTION "Skater Dude Danger Alert Actor Meta-Sprite Data", ROMX

xActorDangerAlertMetasprites::
    metasprite .visible
    metasprite .hidden

.visible
    obj 0, 0, $98, OAMF_PAL1
    obj 0, 8, $9A, OAMF_PAL1
.hidden
    DB METASPRITE_END
