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
    call    LCDMemcopyMap
    
    ; Set up text engine for game descriptions
    ld      a, DESC_TEXT_LINE_LENGTH * 8 - 1
    ld      [wTextLineLength], a
    ld      a, DESC_TEXT_LINE_COUNT
    ld      [wTextNbLines], a
    ; wTextRemainingLines and wNewlinesUntilFull set in DrawDescription
    xor     a, a
    ld      [wTextStackSize], a
    ld      [wTextFlags], a
    ; Delay of 0: Immediately draw all text
    ld      [wTextLetterDelay], a
    ; Set up text tiles
    ld      a, DESC_TEXT_TILES_START
    ; wTextCurTile set in DrawDescription
    ld      [wWrapTileID], a
    ld      a, DESC_TEXT_LAST_TILE
    ld      [wLastTextTile], a
    ld      a, HIGH(vDescTextTiles) & $F0
    ld      [wTextTileBlock], a
    
    ; Reset current selection
    ; TODO: Set it to the previously played game. Would probably require
    ; a separate "current/last game" variable.
    xor     a, a
    ldh     [hCurrentSelection], a
    
    jp      UpdateSelection

SECTION "Game Select Cursor Actor Definition", ROM0

ActorCursorDefinition:
    DB ACTOR_CURSOR
    DB 0, 0
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
    jr      UpdateSelection

MoveRight:
    ldh     a, [c]
    ; Don't move if already at the rightmost column
    ; 2 columns wide: rightmost = bit 0 set
    rrca    ; Move bit 0 to carry
    ret     c
    rlca    ; Undo rrca
    inc     a
    ldh     [c], a
    jr      UpdateSelection

MoveUp:
    ldh     a, [c]
    ; Don't move if already at the topmost row
    cp      a, 2    ; 2 columns wide, 2nd row starts with 2
    ret     c
    ldh     a, [c]
    sub     a, 2    ; 2 columns wide
    ldh     [c], a
    jr      UpdateSelection

MoveDown:
    ldh     a, [c]
    ; Don't move if already at the bottommost row
    cp      a, 4    ; 2 columns wide, 3rd (last) row starts with 4
    ret     nc
    ldh     a, [c]
    add     a, 2    ; 2 columns wide
    ldh     [c], a
    
    ; Fall-through

UpdateSelection:
    ldh     [hScratch1], a  ; Save for getting description
    
    ; Get the new selection's cursor position
    add     a, a
    add     a, LOW(CursorPositionTable)
    ld      l, a
    ASSERT HIGH(CursorPositionTable.end - 1) == HIGH(CursorPositionTable)
    ld      h, HIGH(CursorPositionTable)
    
    ; Update the position of the cursor
    ld      a, [hli]
    ld      [wActorXPosTable], a
    ld      a, [hl]
    ld      [wActorYPosTable], a
    
    ; Clear description box
    ld      hl, vDescText
    ld      de, SCRN_VX_B - DESC_TEXT_LINE_LENGTH
    ld      b, DESC_TEXT_LINE_COUNT
.clearLoop
    ld      c, DESC_TEXT_LINE_LENGTH
.clearRowLoop
    ldh     a, [rSTAT]
    and     a, STATF_BUSY
    jr      nz, .clearRowLoop
    ASSERT DESC_TEXT_BLANK_TILE == 0
    xor     a, a
    ld      [hli], a
    dec     c
    jr      nz, .clearRowLoop
    add     hl, de
    dec     b
    jr      nz, .clearLoop
    
    ; Get pointer to description text
    ldh     a, [hScratch1]  ; a = game number
    ld      b, a
    add     a, a    ; game number * 2 (Pointer)
    add     a, b    ; game number * 3 (+Bank)
    add     a, LOW(DescTextTable)
    ld      l, a
    ASSERT HIGH(DescTextTable.end - 1) == HIGH(DescTextTable)
    ld      h, HIGH(DescTextTable)
    ld      a, [hli]
    ld      b, a    ; b = bank number
    ld      a, [hli]
    ld      h, [hl]
    ld      l, a
    ; hl = pointer to text
    ld      a, TEXT_NEW_STR
    call    PrintVWFText
    ; Reset pen position
    ld      a, DESC_TEXT_LINE_COUNT
    ld      [wTextRemainingLines], a
    ld      [wNewlinesUntilFull], a
    ld      a, DESC_TEXT_TILES_START
    ld      [wTextCurTile], a
    ld      hl, vDescText
    call    SetPenPosition
    ; Draw text
    call    PrintVWFChar
    jp      DrawVWFChars

SECTION "Game Select Screen Cursor Position Table", ROM0

CursorPositionTable:
    ;   X,Y    X,Y
    DB 65,16, 114,16
    DB 65,57, 114,57
    DB 65,98, 114,98
.end
