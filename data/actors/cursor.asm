INCLUDE "constants/hardware.inc"
INCLUDE "constants/game-select.inc"
INCLUDE "constants/actors.inc"
INCLUDE "macros/actors.inc"

SECTION "Game Select Cursor Actor Animation Data", ROMX

xActorCursorAnimation::
    animation Cursor

.loop
    cel out, MUSIC_GAME_SELECT_SPEED * 2
    cel in, MUSIC_GAME_SELECT_SPEED * 2
    goto_cel .loop

SECTION "Game Select Cursor Actor Meta-Sprite Data", ROMX

xActorCursorMetasprites::
    metasprite .out
    metasprite .in

.out
    obj -1, -1, $00, 0
    obj -1, 39, $02, 0
    obj 21, -1, $04, 0
    obj 21, 39, $06, 0
    DB METASPRITE_END
.in
    obj 0, 0, $00, 0
    obj 0, 38, $02, 0
    obj 20, 0, $04, 0
    obj 20, 38, $06, 0
    DB METASPRITE_END
