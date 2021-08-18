INCLUDE "constants/hardware.inc"
INCLUDE "constants/transition.inc"
INCLUDE "constants/games/pancake.inc"

SECTION "Pancake Game Setup", ROMX

xGameSetupPancake::
    ; Set palettes
    ld      a, BGP_PANCAKE
    ldh     [hBGP], a
    ld      a, OBP0_PANCAKE
    ldh     [hOBP0], a
    
    ; Set appropriate LCDC flags
    ld      a, LCDCF_ON | LCDCF_BG8800 | LCDCF_BG9800 | LCDCF_BGON | LCDCF_OBJ16 | LCDCF_OBJON
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
    ASSERT xMap == xBackgroundTiles8800.end
    ; de = xMap
    ld      hl, _SCRN0
    ld      c, SCRN_Y_B
    call    LCDMemcopyMap
    
    ; Enable tile streaming
    ; a = 1
    ldh     [hTileStreamingEnable], a
    
    ; Set up game data
    ld      c, BANK(xHitTablePancake)
    ld      hl, xHitTablePancake
    jp      EngineInit

xBackgroundTiles9000:
    INCBIN "res/pancake/background-1.bg.2bpp", 0, 128 * 16
.end
xBackgroundTiles8800:
    INCBIN "res/pancake/background-1.bg.2bpp", 128 * 16
.end

xMap:
    INCBIN "res/pancake/background-1.bg.tilemap"

SECTION "Pancake Game Loop", ROMX

xGamePancake::
    rst     WaitVBlank
    
    ldh     a, [hTransitionState]
    ASSERT TRANSITION_STATE_OFF == 0
    and     a, a
    jr      z, .noTransition
    
    call    TransitionUpdate
    jr      xGamePancake
    
.noTransition
    call    EngineUpdate
    jr      xGamePancake
