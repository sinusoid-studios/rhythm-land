INCLUDE "constants/hardware.inc"
INCLUDE "constants/game-select.inc"
INCLUDE "constants/actors.inc"
INCLUDE "macros/actors.inc"

SECTION "Game Select Cursor Actor Animation Data", ROMX

xActorCursorAnimation::
    animation Cursor, CURSOR

.game
    cel out, MUSIC_GAME_SELECT_SPEED * 2
    cel in, MUSIC_GAME_SELECT_SPEED * 2
    goto_cel .game

.jukebox
    cel outJukebox, MUSIC_GAME_SELECT_SPEED * 2
    cel inJukebox, MUSIC_GAME_SELECT_SPEED * 2
    goto_cel .jukebox

    ; Cel constant definitions
    def_cel .game, GAME
    def_cel .jukebox, JUKEBOX

SECTION "Game Select Cursor Actor Meta-Sprite Data", ROMX

xActorCursorMetasprites::
    metasprite .out
    metasprite .in
    metasprite .outJukebox
    metasprite .inJukebox

.out
    obj -1, -1, $80, 0
    obj -1, 39, $80, OAMF_XFLIP
    obj 21, -1, $80, OAMF_YFLIP
    obj 21, 39, $80, OAMF_XFLIP | OAMF_YFLIP
    DB METASPRITE_END
.in
    obj 0, 0, $80, 0
    obj 0, 38, $80, OAMF_XFLIP
    obj 20, 0, $80, OAMF_YFLIP
    obj 20, 38, $80, OAMF_XFLIP | OAMF_YFLIP
    DB METASPRITE_END

.outJukebox
    obj -1, -1, $80, 0
    obj -1, 47, $80, OAMF_XFLIP
    obj 4, -1, $80, OAMF_YFLIP
    obj 4, 47, $80, OAMF_XFLIP | OAMF_YFLIP
    DB METASPRITE_END
.inJukebox
    obj 0, 0, $80, 0
    obj 0, 46, $80, OAMF_XFLIP
    obj 3, 0, $80, OAMF_YFLIP
    obj 3, 46, $80, OAMF_XFLIP | OAMF_YFLIP
    DB METASPRITE_END
