INCLUDE "constants/hardware.inc"
INCLUDE "constants/charmap.inc"
INCLUDE "macros/misc.inc"

SECTION "Bad Emulator Warning Screen", ROM0

BadEmulator::
    ; Clear tile
    ld      hl, $9000
    lb      bc, 0, 16
    call    LCDMemsetSmall
    
    ; Clear background map
    ld      hl, _SCRN0
    lb      bc, 0, SCRN_Y_B
    call    LCDMemsetMap
    
    ; Set up text engine
    ld      a, (SCRN_X_B - 2 * 2) * 8 + 1
    ld      [wTextLineLength], a
    ld      a, SCRN_Y_B - 2 * 2
    ld      [wTextNbLines], a
    ld      [wTextRemainingLines], a
    ld      [wNewlinesUntilFull], a
    xor     a, a
    ld      [wTextStackSize], a
    ld      [wTextFlags], a
    ; 0 letter delay -> instantly draw all text
    ld      [wTextLetterDelay], a
    ; Set up text tiles
    ld      a, $80
    ld      [wTextCurTile], a
    ld      [wWrapTileID], a
    ld      a, $FF
    ld      [wLastTextTile], a
    ld      a, $80
    ld      [wTextTileBlock], a
    
    ; Draw text
    ld      b, BANK(xTextBadEmulator)
    ld      hl, xTextBadEmulator
    ld      a, TEXT_NEW_STR
    call    PrintVWFText
    ld      hl, _SCRN0 + (2 * SCRN_VX_B) + 2
    call    SetPenPosition
    call    PrintVWFChar
    call    DrawVWFChars
    
    ; Set palette
    ld      a, %11_11_11_00
    ldh     [rBGP], a
    
    ; Turn the LCD on
    ld      a, LCDCF_ON | LCDCF_BG8800 | LCDCF_BG9800 | LCDCF_BGON
    ldh     [rLCDC], a
    
    ; Lock up
    jr      @

SECTION "Bad Emulator Warning Text", ROMX

xTextBadEmulator:
    DB "BAD EMULATOR!\n"
    DB "\n"
    DB "This emulator appears to be horribly innacurrate.\n"
    DB "Switch to a better one, please.\n"
    DB "\n"
    DB "bgb, SameBoy, and Emulicious are all good options.<END>"
