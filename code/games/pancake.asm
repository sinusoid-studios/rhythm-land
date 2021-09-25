INCLUDE "constants/hardware.inc"
INCLUDE "constants/actors.inc"
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
    INCBIN "res/pancake/background-normal.bg.2bpp", 0, 128 * 16
.end
xBackgroundTiles8800:
    INCBIN "res/pancake/background-normal.bg.2bpp", 128 * 16
.end

xMap:
    INCBIN "res/pancake/background-normal.bg.tilemap"

SECTION "Pancake Game Loop", ROMX

xGamePancake::
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
    jr      nz, xGamePancake
    
    ; Start music
    ld      c, BANK(Inst_Pancake)
    ld      de, Inst_Pancake
    call    Music_PrepareInst
    ld      c, BANK(Music_Pancake)
    ld      de, Music_Pancake
    call    Music_Play
    jr      xGamePancake

.noTransition
    call    EngineUpdate
    call    ActorsUpdate
    jr      xGamePancake

SECTION "Large Pancake Cue", ROMX

xCueLargePancake::
    ; Create a Large Pancake actor
    ASSERT BANK(xActorLargePancakeDefinition) == BANK(@)
    ld      de, xActorLargePancakeDefinition
    jp      ActorNew

xActorLargePancakeDefinition:
    DB ACTOR_LARGE_PANCAKE
    DB PANCAKE_X, PANCAKE_START_Y
    DB 0, PANCAKE_FALL_SPEED

SECTION "Small Pancake Cue", ROMX

xCueSmallPancake::
    ; Create a Small Pancake actor
    ASSERT BANK(xActorSmallPancakeDefinition) == BANK(@)
    ld      de, xActorSmallPancakeDefinition
    jp      ActorNew

xActorSmallPancakeDefinition:
    DB ACTOR_SMALL_PANCAKE
    DB PANCAKE_X, PANCAKE_START_Y
    DB 0, PANCAKE_FALL_SPEED

SECTION "Pancake Actor", ROMX

xActorPancake::
    ; Check if the pancake is finish falling (landed on the pan)
    ld      hl, wActorYPosTable
    add     hl, bc
    ; Negative -> still above the pan
    bit     7, [hl]
    ret     nz
    ld      a, [hl]
    ; Add 1 to check for <= instead of <
    cp      a, PANCAKE_Y + 1
    ret     c
    
    ; Ensure the position is correct before resetting speed
    ld      [hl], PANCAKE_Y
    ; Land on the pan -> stop falling
    ld      hl, wActorYSpeedTable
    add     hl, bc
    ASSERT HIGH(MAX_ACTOR_COUNT - 1) == 0
    ld      [hl], b     ; b = 0
    ret
