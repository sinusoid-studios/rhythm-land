INCLUDE "constants/hardware.inc"
INCLUDE "constants/game-select.inc"
INCLUDE "constants/actors.inc"
INCLUDE "constants/transition.inc"

SECTION UNION "Game Variables", HRAM

hCurrentSelection:
    DS 1

SECTION "Game Select Screen Setup", ROM0

ScreenSetupGameSelect::
    ; Set palette
    ld      a, GAME_SELECT_BGP
    ldh     [hBGP], a
    
    ; Set appropriate LCDC flags
    ld      a, LCDCF_ON | LCDCF_BG8800 | LCDCF_BG9800 | LCDCF_BGON | LCDCF_OBJ16 | LCDCF_OBJON
    ldh     [hLCDC], a
    
    ; Load background tiles
    ld      a, BANK(xBackgroundTiles9000)
    ld      [rROMB0], a
    ld      de, xBackgroundTiles9000
    ld      hl, $9000
    ld      bc, xBackgroundTiles9000.end - xBackgroundTiles9000
    rst     LCDMemcopy
    ld      a, BANK(xBackgroundTiles8800)
    ld      [rROMB0], a
    ld      de, xBackgroundTiles8800
    ld      hl, $8800
    ld      bc, xBackgroundTiles8800.end - xBackgroundTiles8800
    rst     LCDMemcopy
    
    ; Load sprite tiles
    ld      de, SpriteTiles
    ld      hl, $8000
    ld      bc, SpriteTiles.end - SpriteTiles
    rst     LCDMemcopy
    
    ; Reset current selection
    ; TODO: Set it to the previously played game. Would probably require
    ; a separate "current/last game" variable.
    xor     a, a
    ldh     [hCurrentSelection], a
    
    ; Disable tile streaming
    ; a = 0
    ldh     [hTileStreamingEnable], a
    
    ; Create cursor actor
    ld      de, ActorCursorDefinition
    call    ActorNew
    
    ; Load background map
    ld      a, BANK(xMap)
    ld      [rROMB0], a
    ld      de, xMap
    ld      hl, _SCRN0
    ld      c, SCRN_Y_B
    jp      LCDMemcopyMap

SECTION "Game Select Cursor Actor Definition", ROM0

ActorCursorDefinition:
    DB ACTOR_CURSOR
    DB 64, 16
    DB 0, 0

SECTION "Game Select Screen Sprite Tiles", ROM0

SpriteTiles:
    INCBIN "res/game-select/cursor.obj.2bpp"
.end

SECTION "Game Select Screen Background Tiles for $9000", ROMX

xBackgroundTiles9000:
    INCBIN "res/game-select/background.bg.2bpp", 0, 128 * 16
.end

SECTION "Game Select Screen Background Tiles for $8800", ROMX

xBackgroundTiles8800:
    INCBIN "res/game-select/background.bg.2bpp", 128 * 16
.end

SECTION "Game Select Screen Background Map", ROMX

xMap:
    INCBIN "res/game-select/background.bg.tilemap"

SECTION "Game Select Screen Loop", ROM0

ScreenGameSelect::
    rst     WaitVBlank
    
    ; Calling SoundSystem_Process directly instead of SoundUpdate
    ; because this is in ROM0 and there is no sync data to be looking
    ; for
    call    SoundSystem_Process
    
    ldh     a, [hTransitionState]
    ASSERT TRANSITION_STATE_OFF == 0
    and     a, a
    jr      z, .noTransition
    
    call    TransitionUpdate
    
    ; Check if the transition just ended
    ldh     a, [hTransitionState]
    ASSERT TRANSITION_STATE_OFF == 0
    and     a, a
    jr      nz, ScreenGameSelect
    
    ; Start music
    ld      c, BANK(Inst_GameSelect)
    ld      de, Inst_GameSelect
    call    Music_PrepareInst
    ld      c, BANK(Music_GameSelect)
    ld      de, Music_GameSelect
    call    Music_Play
    jr      ScreenGameSelect

.noTransition
    call    ActorsUpdate
    
    ; Keep new keys in B (A overwritten)
    ldh     a, [hNewKeys]
    ld      b, a
    
    ; $FF00 + C = hCurrentSelection
    ld      c, LOW(hCurrentSelection)
    
    ; Move selection
    bit     PADB_LEFT, b
    call    nz, MoveLeft
    bit     PADB_RIGHT, b
    call    nz, MoveRight
    bit     PADB_UP, b
    call    nz, MoveUp
    bit     PADB_DOWN, b
    call    nz, MoveDown
    
    ; If pressed A or START, jump to the selected game
    ld      a, b    ; New keys
    and     a, PADF_A | PADF_START
    jr      z, ScreenGameSelect
    ldh     a, [c]  ; Current selection
    call    TransitionStart
    jr      ScreenGameSelect

SECTION "Game Select Screen Selection", ROM0

MoveLeft:
    ldh     a, [c]
    ; Don't move if already at the leftmost column
    ; 2 columns wide: lefmost = bit 0 reset
    rrca            ; Move bit 0 to carry
    ret     nc
    add     a, a    ; Equivalent to `rlca / dec a` when bit 0 is set
    ldh     [c], a
    jr      UpdateCursor

MoveRight:
    ldh     a, [c]
    ; Don't move if already at the rightmost column
    ; 2 columns wide: rightmost = bit 0 set
    rrca    ; Move bit 0 to carry
    ret     c
    rlca    ; Undo rrca
    inc     a
    ldh     [c], a
    jr      UpdateCursor

MoveUp:
    ldh     a, [c]
    ; Don't move if already at the topmost row
    cp      a, 2    ; 2 columns wide, 2nd row starts with 2
    ret     c
    ldh     a, [c]
    sub     a, 2    ; 2 columns wide
    ldh     [c], a
    jr      UpdateCursor

MoveDown:
    ldh     a, [c]
    ; Don't move if already at the bottommost row
    cp      a, 4    ; 2 columns wide, 3rd (last) row starts with 4
    ret     nc
    ldh     a, [c]
    add     a, 2    ; 2 columns wide
    ldh     [c], a
    
    ; Fall-through

UpdateCursor:
    ; Get the new selection's cursor position
    add     a, a
    add     a, LOW(CursorPositionTable)
    ld      l, a
    ASSERT HIGH(CursorPositionTable.end - 1) == HIGH(CursorPositionTable)
    ld      h, HIGH(CursorPositionTable)
    
    ; Update the position of the cursor
    ld      a, [hli]
    ld      [wActorXPosTable], a
    ld      a, [hli]
    ld      [wActorYPosTable], a
    ret

SECTION "Game Select Screen Cursor Position Table", ROM0

CursorPositionTable:
    ;   X,Y    X,Y
    DB 64,16, 114,16
    DB 64,57, 114,57
    DB 64,98, 114,98
.end
