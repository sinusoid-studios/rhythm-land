INCLUDE "constants/hardware.inc"
INCLUDE "constants/other-hardware.inc"
INCLUDE "constants/game-select.inc"
INCLUDE "constants/actors.inc"
INCLUDE "constants/sfx.inc"
INCLUDE "constants/transition.inc"
INCLUDE "constants/screens.inc"

SECTION UNION "Game Variables", HRAM

hCurrentSelection:
    DS 1

SECTION "Game Select Screen Setup", ROM0

ScreenSetupGameSelect::
    ; Set palette
    ld      a, GAME_SELECT_BGP
    ldh     [hBGP], a
    
    ; Reset scroll
    xor     a, a
    ldh     [hSCX], a
    ldh     [hSCY], a
    
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
    ld      a, BANK(xBackgroundTiles8000)
    ld      [rROMB0], a
    ld      de, xBackgroundTiles8000
    ld      hl, $8000
    ld      bc, xBackgroundTiles8000.end - xBackgroundTiles8000
    rst     LCDMemcopy
    
    ; Load sprite tiles
    ld      de, SpriteTiles
    ld      hl, $8800
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
    ASSERT DESC_TEXT_SPEED == 1
    inc     a
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
    jp      UpdateSelection.initial

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
    INCBIN "res/game-select/background-1.bg.2bpp"
.end

SECTION "Game Select Screen Background Tiles for $8000", ROMX

xBackgroundTiles8000:
    INCBIN "res/game-select/background-2.bg.2bpp"
.end

SECTION "Game Select Screen Background Map", ROMX

xMap:
    INCBIN "res/game-select/background-1.bg.tilemap"
    INCBIN "res/game-select/background-2.bg.tilemap"

SECTION "Game Select Screen Extra LYC Interrupt Handler", ROM0

LYCHandlerGameSelect::
    ld      hl, rLCDC
    
.waitHBlank
    ldh     a, [rSTAT]
    ASSERT STATF_HBL == 0
    and     a, STAT_MODE_MASK
    jr      nz, .waitHBlank
    
    ; Switch tiles
    ASSERT LCDCF_BG8000 != 0
    set     LCDCB_BGTILE, [hl]
    ret

SECTION "Game Select Screen Loop", ROM0

ScreenGameSelect::
    ; Set up extra LYC interrupts
    ld      a, LYCTable.gameSelect - LYCTable
    ldh     [hLYCResetIndex], a
    
.loop
    rst     WaitVBlank
    
    ldh     a, [hTransitionState]
    ldh     [hScratch1], a
    ASSERT TRANSITION_STATE_OFF == 0
    and     a, a
    call    nz, TransitionUpdate
    
    ; Calling SoundSystem_Process directly instead of SoundUpdate
    ; because this is in ROM0 and there is no sync data to be looking
    ; for
    call    SoundSystem_Process
    
    ; Draw 2 characters per frame
    ASSERT DESC_TEXT_SPEED < 2
    call    PrintVWFChar
    call    DrawVWFChars
    call    PrintVWFChar
    call    DrawVWFChars
    
    ; Check if the transition just ended
    ldh     a, [hScratch1]  ; Old transition state
    ld      b, a
    ldh     a, [hTransitionState]
    ; Transition state will only go from transition in to off here
    cp      a, b
    jr      nz, .transitionEnd
    ; Run the body of the game loop if the transition is off
    ASSERT TRANSITION_STATE_OFF == 0
    or      a, b
    jr      z, .noTransition
    jr      .loop

.transitionEnd
    ; Start music
    ld      c, BANK(Inst_GameSelect)
    ld      de, Inst_GameSelect
    call    Music_PrepareInst
    ld      c, BANK(Music_GameSelect)
    ld      de, Music_GameSelect
    call    Music_Play
    jr      .loop

.noTransition
    call    ActorsUpdate
    
    ; Move selection
    ldh     a, [hNewKeys]
    bit     PADB_LEFT, a
    call    nz, MoveLeft
    ldh     a, [hNewKeys]
    bit     PADB_RIGHT, a
    call    nz, MoveRight
    ldh     a, [hNewKeys]
    bit     PADB_UP, a
    call    nz, MoveUp
    ldh     a, [hNewKeys]
    bit     PADB_DOWN, a
    call    nz, MoveDown
    
    ldh     a, [hNewKeys]
    ; B goes back to title screen
    bit     PADB_B, a
    jr      nz, .back
    
    ; If pressed A or START, jump to the selected game
    and     a, PADF_A | PADF_START
    jr      z, .loop
    
    ; Don't allow starting the non-existent game
    ldh     a, [hCurrentSelection]
    cp      a, GAME_NOTHING
    jr      z, ScreenGameSelect
    ; Play start sound effect
    ld      b, SFX_START
    call    SFX_Play
    ; Transition to selected game
    ldh     a, [hCurrentSelection]
    call    TransitionStart
    jr      .loop

.back
    ld      a, SCREEN_TITLE
    call    TransitionStart
    jr      .loop

SECTION "Game Select Screen Selection", ROM0

MoveLeft:
    ld      c, LOW(hCurrentSelection)
    ldh     a, [c]
    cp      a, SCREEN_JUKEBOX
    ret     nc
    ; Move to jukebox if at the leftmost column of games
    ; 2 columns wide: lefmost = bit 0 reset
    rrca            ; Move bit 0 to carry
    jr      nc, .jukebox
    add     a, a    ; Equivalent to `rlca / dec a` when bit 0 is set
    ldh     [c], a
    jr      UpdateSelection

.jukebox
    ld      a, SCREEN_JUKEBOX
    ldh     [c], a
    jr      UpdateSelection

MoveRight:
    ld      c, LOW(hCurrentSelection)
    ldh     a, [c]
    cp      a, SCREEN_JUKEBOX
    jr      nc, .jukebox
    ; Don't move if at the rightmost column of games or at last game
    ; 2 columns wide: rightmost = bit 0 set
    rrca    ; Move bit 0 to carry
    ret     c
    rlca    ; Undo rrca
    cp      a, GAME_COUNT - 1
    ret     z
    inc     a
    ldh     [c], a
    jr      UpdateSelection

.jukebox
    ; Go back to the first game
    xor     a, a
    ldh     [c], a
    jr      UpdateSelection

MoveUp:
    ld      c, LOW(hCurrentSelection)
    ldh     a, [c]
    cp      a, SCREEN_JUKEBOX
    ret     nc
    ; Don't move if already at the topmost row
    cp      a, 2    ; 2 columns wide, 2nd row starts with 2
    ret     c
    ldh     a, [c]
    sub     a, 2    ; 2 columns wide
    ldh     [c], a
    jr      UpdateSelection

MoveDown:
    ld      c, LOW(hCurrentSelection)
    ldh     a, [c]
    ; Don't move if already at the bottommost row of games or jukebox
    ; 2 columns wide
    ASSERT SCREEN_JUKEBOX > GAME_COUNT - 2
    cp      a, GAME_COUNT - 2
    ret     nc
    ldh     a, [c]
    add     a, 2    ; 2 columns wide
    ldh     [c], a
    
    ; Fall-through

UpdateSelection:
    ; Play the selection sound effect
    ld      b, SFX_SELECT
    call    SFX_Play
    
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
    
    ; Get the new selection's cursor position
    ldh     a, [hCurrentSelection]
.initial
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
    
    ; Use the correct cursor size
    ld      hl, wActorCelTable
    ldh     a, [hCurrentSelection]
    ld      b, a    ; Save for getting description
    cp      a, SCREEN_JUKEBOX
    ld      a, [hl]
    jr      z, .jukebox
    and     a, ~1
    jr      z, .doneCel
    ld      a, [hl]
    sub     a, CEL_CURSOR_JUKEBOX - CEL_CURSOR_GAME
    jr      .setCel
.jukebox
    and     a, ~1
    jr      nz, .doneCel
    ld      a, [hl]
    add     a, CEL_CURSOR_JUKEBOX - CEL_CURSOR_GAME
.setCel
    ld      [hl], a
.doneCel
    
    ; Get pointer to description text
    ld      a, b    ; a = game number
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
    jp      SetPenPosition

SECTION "Game Select Screen Cursor Position Table", ROM0

CursorPositionTable:
    ;   X,Y    X,Y
    DB 65,16, 114,16
    DB 65,57, 114,57
    DB 65,98
    ; Jukebox
    DB 5, 116
.end
