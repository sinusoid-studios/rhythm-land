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
    
    ; Load background tiles
    ASSERT BANK(xBackgroundTiles) == BANK(@)
    ld      de, xBackgroundTiles
    ld      hl, $9000
    ld      bc, xBackgroundTiles.end - xBackgroundTiles
    rst     LCDMemcopy
    
    ; Load background map
    ASSERT BANK(xMap) == BANK(@)
    ASSERT xMap == xBackgroundTiles.end
    ; de = xMap
    ld      hl, _SCRN0
    ld      c, SCRN_Y_B
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

xMap:
    INCBIN "res/battleship/background.bg.tilemap"

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
    jr      xGameBattleship
