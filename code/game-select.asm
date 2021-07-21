INCLUDE "hardware.inc"
INCLUDE "constants/game-select.inc"

SECTION "Currently Selected Game ID", HRAM

hCurrentSelection:
    DS 1

SECTION "Game Select Screen Setup", ROM0

SetupGameSelectScreen::
    ; Load tiles
    ld      de, HexDigitTiles
    ld      hl, $9000
    ld      bc, HexDigitTiles.end - HexDigitTiles
    rst     LCDMemcopy
    
    ; Clear background map
    ld      hl, _SCRN0
    ld      de, SCRN_VX_B - SCRN_X_B
    ld      b, SCRN_Y_B
.rowLoop
    DEF UNROLL = (16 - 2) / 2
    ld      c, SCRN_X_B / UNROLL
.tileLoop
    ldh     a, [rSTAT]
    and     a, STATF_BUSY
    jr      nz, .tileLoop
    ; 2 cycles
    ld      a, GAME_SELECT_BLANK_TILE
    REPT UNROLL
    ld      [hli], a    ; 2 cycles
    ENDR
    dec     c
    jr      nz, .tileLoop
    
.remainingTiles
    ldh     a, [rSTAT]
    and     a, STATF_BUSY
    jr      nz, .remainingTiles
    ; 2 cycles
    ld      a, GAME_SELECT_BLANK_TILE
    REPT SCRN_X_B % UNROLL
    ld      [hli], a    ; 2 cycles
    ENDR
    
    add     hl, de
    dec     b
    jr      nz, .rowLoop
    
    ; Set up defaults
    ld      hl, hCurrentSelection
    ld      [hl], 0
    ld      de, vGameID
    ; Draw the initial game ID
    jp      UpdateGameID

SECTION "Game Select Screen Loop", ROM0

GameSelectScreen::
    ld      hl, hCurrentSelection
    ld      de, vGameID
.loop
    rst     WaitVBlank
    
    ldh     a, [hNewKeys]
    ld      b, a        ; Save in the unmodified b register
    
    bit     PADB_UP, b
    jr      nz, .increment
    bit     PADB_RIGHT, b
    jr      nz, .add16
    
    bit     PADB_DOWN, b
    jr      nz, .decrement
    bit     PADB_LEFT, b
    jr      nz, .sub16
    
    ld      a, b
    and     a, PADF_A | PADF_START
    jr      z, .loop

    ; Jump to the selected game
    ld      a, [hl]
    jp      Transition

.increment
    inc     [hl]
    call    UpdateGameID
    jr      .loop
.add16
    ld      a, [hl]
    add     a, 16
    ld      [hl], a
    call    UpdateGameID
    jr      .loop

.decrement
    dec     [hl]
    call    UpdateGameID
    jr      .loop
.sub16
    ld      a, [hl]
    sub     a, 16
    ld      [hl], a
    call    UpdateGameID
    jr      .loop

SECTION "Game Select Screen Game ID Update", ROM0

; @param    hl  Pointer to game ID
; @param    de  Pointer to destination on map
UpdateGameID:
    ldh     a, [rSTAT]
    and     a, STATF_BUSY
    jr      nz, UpdateGameID
    
    ; High nibble
    ld      a, [hl]     ; 2 cycles
    swap    a           ; 2 cycles
    and     a, $0F      ; 2 cycles
    ld      [de], a     ; 2 cycles
    inc     e           ; 1 cycle
    ; Low nibble
    ld      a, [hl]     ; 2 cycles
    and     a, $0F      ; 2 cycles
    ld      [de], a     ; 2 cycles
    ; Total 15 cycles
    
    ASSERT HIGH(vGameID + 1) == HIGH(vGameID)
    ld      e, LOW(vGameID)
    ret
