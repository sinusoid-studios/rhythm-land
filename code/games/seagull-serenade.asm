INCLUDE "constants/hardware.inc"
INCLUDE "constants/actors.inc"
INCLUDE "constants/transition.inc"
INCLUDE "constants/games/seagull-serenade.inc"

SECTION "Seagull Serenade Game Setup", ROMX

xGameSetupSeagullSerenade::
    ; Set palettes
    ld      a, SEAGULL_SERENADE_BGP
    ldh     [hBGP], a
    ld      a, SEAGULL_SERENADE_OBP0
    ldh     [hOBP0], a
    
    ; Set appropriate LCDC flags
    ld      a, LCDCF_ON | LCDCF_BG8800 | LCDCF_BG9800 | LCDCF_BGON | LCDCF_OBJ16 | LCDCF_OBJON
    ldh     [hLCDC], a
    
    ; Load background tiles
    ASSERT BANK(xBackgroundTilesSeagullSerenade9000) == BANK(@)
    ld      de, xBackgroundTilesSeagullSerenade9000
    ld      hl, $9000
    ld      bc, xBackgroundTilesSeagullSerenade9000.end - xBackgroundTilesSeagullSerenade9000
    rst     LCDMemcopy
    ASSERT BANK(xBackgroundTilesSeagullSerenade8800) == BANK(@)
    ASSERT xBackgroundTilesSeagullSerenade8800 == xBackgroundTilesSeagullSerenade9000.end
    ; de = xBackgroundTilesSeagullSerenade8800
    ld      hl, $8800
    ld      bc, xBackgroundTilesSeagullSerenade8800.end - xBackgroundTilesSeagullSerenade8800
    rst     LCDMemcopy
    
    ; Load background map
    ASSERT BANK(xMapSeagullSerenade) == BANK(@)
    ld      de, xMapSeagullSerenade
    ld      hl, _SCRN0
    call    LCDMemcopyMap
    
    ; Create seagull actors
    ld      de, xActorSeagullDefinitions
    ASSERT NUM_SEAGULLS == 3
    call    ActorsNew
    call    ActorsNew
    call    ActorsNew
    
    ; Prepare music
    ld      c, BANK(Inst_SeagullSerenade)
    ld      de, Inst_SeagullSerenade
    jp      Music_PrepareInst

xActorSeagullDefinitions:
    ; Seagull 1
    DB ACTOR_SEAGULL_1
    DB SEAGULL_1_X, SEAGULL_1_Y
    DB 0, 0
    ; Seagull 2
    DB ACTOR_SEAGULL_2
    DB SEAGULL_2_X, SEAGULL_2_Y
    DB 0, 0
    ; Seagull 3
    DB ACTOR_SEAGULL_3
    DB SEAGULL_3_X, SEAGULL_3_Y
    DB 0, 0

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
    
    ldh     a, [hTransitionState]
    ASSERT TRANSITION_STATE_OFF == 0
    and     a, a
    jr      z, .noTransition
    
    call    TransitionUpdate
    
    ldh     a, [hTransitionState]
    ASSERT TRANSITION_STATE_OFF == 0
    and     a, a
    jr      nz, xGameSeagullSerenade
    
    ; Start music
    ld      c, BANK(Music_SeagullSerenade)
    ld      de, Music_SeagullSerenade
    call    Music_Play
    jr      xGameSeagullSerenade

.noTransition
    call    ActorsUpdate
    jr      xGameSeagullSerenade

SECTION "Seagull Serenade Seagull Actor", ROMX

xActorSeagull::
    ; Check for sync actions
    ld      a, [wMusicSyncData]
    ASSERT SYNC_SEAGULL_SERENADE_GROOVE == 1
    dec     a
    ret     nz
    
    ; Stop bobbing and start to really get in the groove
    ld      a, CEL_SEAGULL_GROOVE
    jp      ActorsSetCel
