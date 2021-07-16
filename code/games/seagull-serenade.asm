INCLUDE "defines.inc"

SECTION "Seagull Serenade Game Setup", ROMX

xGameSetupSeagullSerenade::
    ; Load background tiles
    ASSERT BANK(xBackgroundTilesSeagullSerenade9000) == BANK(@)
    ld      de, xBackgroundTilesSeagullSerenade9000
    ld      hl, $9000
    ld      bc, xBackgroundTilesSeagullSerenade9000.end - xBackgroundTilesSeagullSerenade9000
    rst     LCDMemcopy
    ASSERT BANK(xBackgroundTilesSeagullSerenade8800) == BANK(@)
    ld      de, xBackgroundTilesSeagullSerenade8800
    ld      hl, $8800
    ld      bc, xBackgroundTilesSeagullSerenade8800.end - xBackgroundTilesSeagullSerenade8800
    rst     LCDMemcopy
    
    ; Load background map
    ASSERT BANK(xMapSeagullSerenade) == BANK(@)
    ld      de, xMapSeagullSerenade
    ld      hl, _SCRN0
    jp      LCDMemcopyMap

xBackgroundTilesSeagullSerenade9000:
    INCBIN "res/seagull-serenade/background.bg.2bpp", 0, 128 * 16
.end
xBackgroundTilesSeagullSerenade8800:
    INCBIN "res/seagull-serenade/background.bg.2bpp", 128 * 16
.end

xMapSeagullSerenade:
    INCBIN "res/seagull-serenade/background.bg.tilemap"

SECTION "Seagull Serenade Game Loop", ROMX

xGameSeagullSerenade::
    rst     WaitVBlank
    jr      xGameSeagullSerenade
