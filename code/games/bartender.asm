INCLUDE "constants/hardware.inc"
INCLUDE "constants/transition.inc"
INCLUDE "constants/games/bartender.inc"

SECTION "Bartender Game Setup", ROMX

xGameSetupBartender::
    ; Set palettes
    ld      a, BARTENDER_BGP
    ldh     [hBGP], a
    ASSERT BARTENDER_OBP1 & ~%11 == BARTENDER_BGP & ~%11
    ldh     [hOBP1], a
    ld      a, BARTENDER_OBP0
    ldh     [hOBP0], a
    
    ; Set appropriate LCDC flags
    ld      a, LCDCF_ON | LCDCF_BG8800 | LCDCF_BG9800 | LCDCF_BGON
    ldh     [hLCDC], a
    
    ; Load background tiles
    ASSERT BANK(xBackgroundTiles9000) == BANK(@)
    ld      de, xBackgroundTiles9000
    ld      hl, $9000
    ld      bc, xBackgroundTiles9000.end - xBackgroundTiles9000
    rst     LCDMemcopy
    ASSERT BANK(xBackgroundTiles8800) == BANK(@)
    ASSERT xBackgroundTiles8800 == xBackgroundTiles9000.end
    ; de = xBackgroundTiles8800
    ld      hl, $8800
    ld      bc, xBackgroundTiles8800.end - xBackgroundTiles8800
    rst     LCDMemcopy
    
    ; Load background map
    ASSERT BANK(xMap) == BANK(@)
    ld      de, xMap
    ld      hl, _SCRN0
    ld      c, SCRN_Y_B
    jp      LCDMemcopyMap

xBackgroundTiles9000:
    INCBIN "res/bartender/background.bg.2bpp", 0, 128 * 16
.end
xBackgroundTiles8800:
    INCBIN "res/bartender/background.bg.2bpp", 128 * 16
.end

xMap:
    INCBIN "res/bartender/background.bg.tilemap"

SECTION "Bartender Game Loop", ROMX

xGameBartender::
    rst     WaitVBlank
    
    ; Check if currently transitioning to another screen
    ldh     a, [hTransitionState]
    ASSERT TRANSITION_STATE_OFF == 0
    and     a, a
    jr      z, xGameBartender
    
    ; Update transition if currently transitioning
    call    TransitionUpdate
    jr      xGameBartender
