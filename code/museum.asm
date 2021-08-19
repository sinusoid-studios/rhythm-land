INCLUDE "constants/hardware.inc"
INCLUDE "constants/museum.inc"
INCLUDE "constants/transition.inc"

SECTION UNION "Background-Only Tiles", VRAM[$9000]

vJukeboxBackgroundTile:
    DS 16

vJukeboxTextTiles:
    DS JUKEBOX_LINE_LENGTH * JUKEBOX_LINE_COUNT * 16
.end

SECTION "Museum Setup", ROM0

ScreenSetupMuseum::
    ; Clear tile
    ld      c, CEIL(DIV(16.0, 7.0)) >> 16
    ld      hl, $9000
.clearTileLoop
    ldh     a, [rSTAT]
    and     a, STATF_BUSY
    jr      nz, .clearTileLoop
    
    xor     a, a        ; 1 cycle
    ld      [hli], a    ; 2 cycles
    ld      [hli], a    ; 2 cycles
    ld      [hli], a    ; 2 cycles
    ld      [hli], a    ; 2 cycles
    ld      [hli], a    ; 2 cycles
    ld      [hli], a    ; 2 cycles
    ld      [hli], a    ; 2 cycles
    ; Total 15 cycles
    dec     c
    jr      nz, .clearTileLoop
    
    ; Clear background map
    ld      hl, _SCRN0
    ld      de, SCRN_VX_B - SCRN_X_B
    ld      b, SCRN_Y_B
.rowLoop
    DEF UNROLL = (16 - 1) / 2
    ld      c, SCRN_X_B / UNROLL
.tileLoop
    ldh     a, [rSTAT]
    and     a, STATF_BUSY
    jr      nz, .tileLoop
    ASSERT LOW(vJukeboxBackgroundTile / 16) == 0
    xor     a, a        ; 1 cycle
    REPT UNROLL
    ld      [hli], a    ; 2 cycles
    ENDR
    dec     c
    jr      nz, .tileLoop
    
.remainingTiles
    ldh     a, [rSTAT]
    and     a, STATF_BUSY
    jr      nz, .remainingTiles
    ASSERT LOW(vJukeboxBackgroundTile / 16) == 0
    xor     a, a        ; 1 cycle
    REPT SCRN_X_B % UNROLL
    ld      [hli], a    ; 2 cycles
    ENDR
    
    add     hl, de
    dec     b
    jr      nz, .rowLoop
    
    ; Set up text engine for jukebox
    ld      a, JUKEBOX_LINE_LENGTH * 8 + 1
    ld      [wTextLineLength], a
    ; Each entry is 1 line
    ld      a, 1
    ld      [wTextNbLines], a
    ld      [wTextRemainingLines], a
    ld      [wNewlinesUntilFull], a
    xor     a, a
    ld      [wTextStackSize], a
    ld      [wTextFlags], a
    ; 0 letter delay -> instantly draw all text
    ld      [wTextLetterDelay], a
    ; Set up text tiles
    ld      a, LOW(vJukeboxTextTiles / 16)
    ld      [wTextCurTile], a
    ld      [wWrapTileID], a
    ld      a, LOW(vJukeboxTextTiles.end / 16) - 1
    ld      [wLastTextTile], a
    ld      a, HIGH(vJukeboxTextTiles) & $F0
    ld      [wTextTileBlock], a
    
    ; Draw music names
    xor     a, a
    ; Carry cleared from xor
    DB      $DA     ; jp c, a16 to consume the next 2 bytes
.loop
    ldh     a, [hScratch1]
    ; a = music number
    ld      c, a
    add     a, a
    add     a, c
    add     a, LOW(MusicNameTable)
    ld      l, a
    ASSERT WARN, HIGH(MusicNameTable.end - 1) != HIGH(MusicNameTable)
    adc     a, HIGH(MusicNameTable)
    sub     a, l
    ld      h, a
    
    ld      a, [hli]
    ld      b, a    ; b = bank number
    ld      a, [hli]
    ld      h, [hl]
    ld      l, a
    
    ld      a, TEXT_NEW_STR
    call    PrintVWFText
    ld      hl, vJukeboxText
    ldh     a, [hScratch1]
    ASSERT JUKEBOX_LINE_GAP == SCRN_VX_B * 2
    ASSERT HIGH((MusicNameTable.end - MusicNameTable) / (1 + 2) * JUKEBOX_LINE_GAP / 2) == 0
    swap    a       ; a * 16
    add     a, a    ; a * 32 or SCRN_VX_B
    add     a, a    ; a * SCRN_VX_B * 2 or JUKEBOX_LINE_GAP
    ld      e, a
    ld      d, 0
    ASSERT WARN, HIGH((MusicNameTable.end - MusicNameTable) / (1 + 2) * JUKEBOX_LINE_GAP) != 0
    rl      d       ; Carry from last `add a, a`
    add     hl, de
    call    SetPenPosition
    call    PrintVWFChar
    call    DrawVWFChars
    
    ldh     a, [hScratch1]
    inc     a
    ldh     [hScratch1], a
    cp      a, (MusicNameTable.end - MusicNameTable) / (1 + 2)
    jr      c, .loop
    ret

SECTION "Museum", ROM0

ScreenMuseum::
    rst     WaitVBlank
    
    ldh     a, [hTransitionState]
    ASSERT TRANSITION_STATE_OFF == 0
    and     a, a
    jr      z, .noTransition
    
    call    TransitionUpdate
    jr      ScreenMuseum

.noTransition
    call    PrintVWFChar
    call    DrawVWFChars
    jr      ScreenMuseum
