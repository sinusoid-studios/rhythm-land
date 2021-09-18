INCLUDE "constants/hardware.inc"
INCLUDE "constants/transition.inc"
INCLUDE "constants/games/battleship.inc"

SECTION "Battleship Game Setup", ROMX

xGameSetupBattleship::
    ; Set palette
    ld      a, BATTLESHIP_BGP
    ldh     [hBGP], a
    
    ; Set appropriate LCDC flags
    ld      a, LCDCF_ON | LCDCF_BG8800 | LCDCF_BG9800 | LCDCF_BGON
    ldh     [hLCDC], a
    
    ; Set initial Y scroll
    ld      a, BATTLESHIP_INITIAL_Y
    ldh     [hSCY], a
    
    ; Load background tiles
    ASSERT BANK(xBackgroundTiles) == BANK(@)
    ld      de, xBackgroundTiles
    ld      hl, $9000
    ld      bc, xBackgroundTiles.end - xBackgroundTiles
    rst     LCDMemcopy
    
    ; Load first background map
    ASSERT BANK(xMap1) == BANK(@)
    ; Reuse the same part of the repeating block for the top of the
    ; background
    ASSERT xMap1 == xBackgroundTiles.end
    ; de = xMap1
    ld      hl, _SCRN0
    ld      c, BATTLESHIP_OCEAN_REPEAT_SIZE
    call    LCDMemcopyMap
    ld      de, xMap1
    ld      c, BATTLESHIP_OCEAN_REPEAT_SIZE
    call    LCDMemcopyMap
    ld      de, xMap1
    ld      c, (xMap1.end - xMap1) / SCRN_X_B
    call    LCDMemcopyMap
    ; Load second background map
    ASSERT BANK(xMap2) == BANK(@)
    ASSERT xMap2 == xMap1.end
    ; de = xMap2
    ld      hl, _SCRN1
    ld      c, BATTLESHIP_OCEAN_REPEAT_SIZE
    call    LCDMemcopyMap
    ld      de, xMap2
    ld      c, BATTLESHIP_OCEAN_REPEAT_SIZE
    call    LCDMemcopyMap
    ld      de, xMap2
    ld      c, (xMap2.end - xMap2) / SCRN_X_B
    call    LCDMemcopyMap
    
    ; Set up game data
    ld      c, BANK(xHitTableBattleship)
    ld      hl, xHitTableBattleship
    call    EngineInit
    
    ; Prepare music
    ld      c, BANK(Inst_Battleship)
    ld      de, Inst_Battleship
    jp      Music_PrepareInst

xBackgroundTiles:
    INCBIN "res/battleship/background.bg.2bpp"
.end

xMap1:
    INCBIN "res/battleship/background.bg.tilemap", 0, BATTLESHIP_OCEAN_REPEAT_SIZE * 2 * SCRN_X_B
.end
xMap2:
    INCBIN "res/battleship/background.bg.tilemap", BATTLESHIP_OCEAN_REPEAT_SIZE * 2 * SCRN_X_B
.end

SECTION "Battleship Game Loop", ROMX

xGameBattleship::
    rst     WaitVBlank
    
    ; Check if currently transitioning to another screen
    ldh     a, [hTransitionState]
    ASSERT TRANSITION_STATE_OFF == 0
    and     a, a
    jr      z, .noTransition
    
    call    TransitionUpdate
    
    ; Check if the transition just ended
    ldh     a, [hTransitionState]
    ASSERT TRANSITION_STATE_OFF == 0
    and     a, a
    jr      nz, xGameBattleship
    
    ; Start music
    ld      c, BANK(Music_Battleship)
    ld      de, Music_Battleship
    call    Music_Play
    jr      xGameBattleship

.noTransition
    call    EngineUpdate
    
    ; Scroll the background
    ld      hl, hSCY
    dec     [hl]
    jr      nz, .noReset
    ld      [hl], BATTLESHIP_INITIAL_Y
.noReset
    ; Update the background (ocean waves) every 16 frames
    ldh     a, [hFrameCounter]
    and     a, 15
    jr      nz, xGameBattleship
    ; Toggle the background tilemap
    ldh     a, [hLCDC]
    xor     a, LCDCF_BG9800 ^ LCDCF_BG9C00
    ldh     [hLCDC], a
    jr      xGameBattleship
