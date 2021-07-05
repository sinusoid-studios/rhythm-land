INCLUDE "defines.inc"

SECTION "Game Variables", HRAM

hCurrentGame::
    DS 1

SECTION "Game Select Screen", ROM0

GameSelect::
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
    ld      hl, hCurrentGame
    ld      [hl], 0
    ld      de, vGameID
    ; Draw the initial game ID
    call    UpdateGameID

.loop
    ; Wait for VBlank
    halt
    ldh     a, [hVBlankFlag]
    and     a, a
    jr      z, .loop
    xor     a, a
    ldh     [hVBlankFlag], a
    
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
    and     a, PADB_A | PADB_START
    jr      z, .loop

    ; Start the selected game
    ld      a, [hl]
    add     a, a        ; a * 2 (Pointer)
    add     a, [hl]     ; a * 3 (+Bank)
    add     a, LOW(GameTable)
    ld      l, a
    ASSERT HIGH(GameTable.end - 1) == HIGH(GameTable)
    ld      h, HIGH(GameTable)
    
    ; Jump to game
    ld      a, [hli]
    ld      [rROMB0], a
    ldh     [hCurrentBank], a
    ld      a, [hli]
    ld      h, [hl]
    ld      l, a
    jp      hl

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
