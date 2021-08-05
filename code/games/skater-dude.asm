INCLUDE "constants/hardware.inc"
INCLUDE "constants/engine.inc"
INCLUDE "constants/actors.inc"
INCLUDE "constants/sfx.inc"
INCLUDE "constants/games.inc"
INCLUDE "constants/transition.inc"
INCLUDE "constants/games/skater-dude.inc"

SECTION UNION "Game Variables", HRAM

; When the game starts or ends, Skater Dude skates on or off the screen
hSkaterDudeState:
    DS 1
; Index into Skater Dude's jump position table
hSkaterDudePosIndex:
    DS 1
hSkaterDudePosCountdown:
    DS 1

; Number of frames left in slo-mo
hSloMoCountdown::
    DS 1

SECTION "Skater Dude Game Setup", ROMX

xGameSetupSkaterDude::
    ; Set palettes
    ld      a, SKATER_DUDE_BGP
    ldh     [hBGP], a
    ASSERT SKATER_DUDE_OBP1 & ~%11 == SKATER_DUDE_BGP & ~%11
    ldh     [hOBP1], a
    ld      a, SKATER_DUDE_OBP0
    ldh     [hOBP0], a
    
    ; Set appropriate LCDC flags
    ld      a, LCDCF_ON | LCDCF_BG8800 | LCDCF_BG9800 | LCDCF_BGON | LCDCF_OBJ16 | LCDCF_OBJON
    ldh     [hLCDC], a
    
    ASSERT SKATER_DUDE_STATE_IN == 0
    xor     a, a
    ldh     [hSkaterDudeState], a
    
    ; Initially no slo-mo
    ASSERT SKATER_DUDE_NO_SLO_MO == 0 - 1
    dec     a
    ldh     [hSloMoCountdown], a
    
    ; Load background tiles
    ASSERT BANK(xBackgroundTiles) == BANK(@)
    ld      de, xBackgroundTiles
    ld      hl, $9000
    ld      bc, xBackgroundTiles.end - xBackgroundTiles
    rst     LCDMemcopy
    
    ; Load sprite tiles
    ASSERT BANK(xSpriteTiles) == BANK(@)
    ASSERT xSpriteTiles == xBackgroundTiles.end
    ld      hl, $8000
    ld      bc, xSpriteTiles.end - xSpriteTiles
    rst     LCDMemcopy
    
    ; Set up the background map
    ld      hl, hMapWidth
    ld      [hl], MAP_SKATER_DUDE_WIDTH
    ASSERT hMapHeight == hMapWidth + 1
    inc     l
    ld      [hl], MAP_SKATER_DUDE_HEIGHT
    ASSERT hMapBank == hMapHeight + 1
    inc     l
    ld      [hl], BANK(xMap)
    ASSERT hMapPointer == hMapBank + 1
    inc     l
    ld      [hl], LOW(xMap)
    inc     l
    ld      [hl], HIGH(xMap)
    ; Set initial map position
    ASSERT hMapXPos == hMapPointer + 2
    inc     l
    ld      [hl], LOW(MAP_SKATER_DUDE_START_X)
    inc     l
    ld      [hl], HIGH(MAP_SKATER_DUDE_START_X)
    ASSERT hMapYPos == hMapXPos + 2
    inc     l
    ASSERT MAP_SKATER_DUDE_START_Y == 0
    xor     a, a
    ld      [hli], a
    ld      [hl], a
    ; Draw the initial visible map
    call    MapDraw
    
    ; No tile streaming in this game
    xor     a, a
    ldh     [hTileStreamingEnable], a
    
    ; Create the Skater Dude actor
    ASSERT BANK(xActorSkaterDudeDefinition) == BANK(@)
    ld      de, xActorSkaterDudeDefinition
    call    ActorNew
    ld      a, -1
    ldh     [hSkaterDudePosIndex], a
    
    ; Set up game data
    ld      c, BANK(xHitTableSkaterDude)
    ld      hl, xHitTableSkaterDude
    call    EngineInit
    
    ; Prepare music
    ld      c, BANK(Inst_SkaterDude)
    ld      de, Inst_SkaterDude
    jp      Music_PrepareInst

xBackgroundTiles:
    INCBIN "res/skater-dude/background.bg.2bpp"
.end

xSpriteTiles:
    ; Remove the first 2 tiles which are blank on purpose to get rid of
    ; any blank objects in the image
    INCBIN "res/skater-dude/skater-dude.obj.2bpp", 16 * 2
    INCBIN "res/skater-dude/skateboard.obj.2bpp", 16 * 2
    INCBIN "res/skater-dude/danger-alert.obj.2bpp"
    INCBIN "res/skater-dude/car.obj.2bpp"
    INCBIN "res/skater-dude/log.obj.2bpp", 16 * 2
    INCBIN "res/skater-dude/oil-barrel.obj.2bpp", 16 * 2
.end

xActorSkaterDudeDefinition:
    DB ACTOR_SKATER_DUDE
    DB SKATER_DUDE_START_X, SKATER_DUDE_Y
    DB SKATER_DUDE_IN_SPEED, 0

SECTION "Skater Dude Game Background Map", ROMX

xMap:
    INCBIN "res/skater-dude/background.bg.tilemap"

SECTION "Skater Dude Game Loop", ROMX

xGameSkaterDude::
    rst     WaitVBlank
    
    ldh     a, [hTransitionState]
    ASSERT TRANSITION_STATE_OFF == 0
    and     a, a
    jr      z, .noTransition
    
    call    TransitionUpdate
    call    MapScrollLeft
    
    ldh     a, [hTransitionState]
    ASSERT TRANSITION_STATE_OFF == 0
    and     a, a
    jr      nz, xGameSkaterDude
    
    ; Start music
    ld      c, BANK(Music_SkaterDude)
    ld      de, Music_SkaterDude
    call    Music_Play
    jr      xGameSkaterDude

.noTransition
    call    EngineUpdate
    
    call    ActorsUpdate
    ldh     a, [hSloMoCountdown]
    ASSERT SKATER_DUDE_NO_SLO_MO == -1
    inc     a
    call    z, MapScrollLeft
    
    ; If the game is over, go to the overall rating screen
    ldh     a, [hSkaterDudeState]
    cp      a, SKATER_DUDE_STATE_END
    jr      z, .finished
    
    ld      hl, hSloMoCountdown
    ld      a, [hl]
    ASSERT SKATER_DUDE_NO_SLO_MO == -1
    inc     a
    jr      z, xGameSkaterDude
    dec     [hl]
    jr      xGameSkaterDude

.finished
    ld      a, ID_RATING_SCREEN
    call    TransitionStart
    jr      xGameSkaterDude

SECTION "Skater Dude Danger Alert Cue", ROMX

xCueDangerAlert::
    ; Create a Danger Alert actor
    ASSERT BANK(xActorDangerAlertDefinition) == BANK(@)
    ld      de, xActorDangerAlertDefinition
    jp      ActorNew

xActorDangerAlertDefinition:
    DB ACTOR_DANGER_ALERT
    DB DANGER_ALERT_X, DANGER_ALERT_Y
    DB 0, 0

SECTION "Skater Dude Obstacle Cue", ROMX

xCueObstacle::
    ; Create a random type of obstacle
    call    Random
    ASSERT NUM_OBSTACLES == 3
    and     a, 3
    cp      a, NUM_OBSTACLES
    jr      c, .obstacleOk
    ; Cars would realistically be more common on the road, so go with
    ; that
    ASSERT ACTOR_CAR - ACTOR_OBSTACLES_START == 0
    xor     a, a
.obstacleOk
    ; Get pointer to the actor definition
    ld      b, a
    add     a, a    ; a * 2 (X, Y)
    add     a, a    ; a * 4 (X speed, Y speed)
    add     a, b    ; a * 5 (Type)
    ASSERT BANK(xObstacleDefinitions) == BANK(@)
    add     a, LOW(xObstacleDefinitions)
    ld      e, a
    ASSERT HIGH(xObstacleDefinitions.end - 1) == HIGH(xObstacleDefinitions)
    ld      d, HIGH(xObstacleDefinitions)
    jp      ActorNew

xObstacleDefinitions:
    ; Car
    DB ACTOR_CAR
    DB OBSTACLE_X, OBSTACLE_Y
    DB OBSTACLE_SPEED, 0
    ; Log
    DB ACTOR_LOG
    DB OBSTACLE_X, OBSTACLE_Y
    DB OBSTACLE_SPEED, 0
    ; Oil Barrel
    DB ACTOR_OIL_BARREL
    DB OBSTACLE_X, OBSTACLE_Y
    DB OBSTACLE_SPEED, 0
.end

SECTION "Skater Dude Slo-Mo Cue", ROMX

xCueSloMo::
    ; Start slo-mo
    ld      a, SKATER_DUDE_SLO_MO_DURATION
    ldh     [hSloMoCountdown], a
    ret

SECTION "Skater Dude Actor", ROMX

xActorSkaterDude::
    ; Game hasn't started yet -> skate on-screen
    ldh     a, [hSkaterDudeState]
    ASSERT SKATER_DUDE_STATE_IN == 0
    and     a, a
    jp      z, .skatingOnscreen
    ; Currently skating off-screen
    ASSERT SKATER_DUDE_STATE_OUT == 1
    dec     a
    ; Nothing to do while skating out
    jp      z, .skatingOffscreen
    
    ; Music ended -> skate off-screen
    ld      a, [wMusicSyncData]
    ASSERT SYNC_SKATER_DUDE_END == 1
    dec     a
    jp      z, .skateOffscreen
    
    ; If Skater Dude isn't on the ground (fallen), he should be "moving"
    ; The background scrolls so to "move", Skater Dude must stay in
    ; place
    ld      hl, wActorCelOverrideTable
    add     hl, bc
    ld      a, [hl]
    ASSERT ANIMATION_OVERRIDE_NONE == -1
    inc     a
    ; No animation override -> skating animation
    jr      z, .moving
    ; Add 1 to compensate for inc
    cp      a, CEL_SKATER_DUDE_FALLING + 1
    jr      nc, .notMoving
    
.moving
    ; Skater Dude is either skating or jumping -> "move"
    ld      hl, wActorXSpeedTable
    add     hl, bc
    ld      [hl], 0
    ; Make sure the position is correct after falling
    ld      hl, wActorXPosTable
    add     hl, bc
    ld      [hl], SKATER_DUDE_X
    
.notMoving
    ; If Skater Dude is currently jumping, update his Y position
    ldh     a, [hSkaterDudePosIndex]
    inc     a
    jr      z, .notJumping
    
    ; If not currently in slo-mo, the countdown works a little
    ; differently
    ldh     a, [hSloMoCountdown]
    ASSERT SKATER_DUDE_NO_SLO_MO == -1
    inc     a
    jr      nz, .sloMo
    
    ; In not in slo-mo, subtract the denominator of slo-mo speed instead
    ; of 1 (denominator in normal speed)
    ldh     a, [hSkaterDudePosCountdown]
    sub     a, SKATER_DUDE_SLO_MO_DIVIDE
    ldh     [hSkaterDudePosCountdown], a
    ; If less than or equal to 0, update Skater Dude's position
    jr      z, .jumping
    jr      nc, .notJumping
    jr      .jumping
    
.sloMo
    ; In slo-mo, simply decrement the countdown
    ld      hl, hSkaterDudePosCountdown
    dec     [hl]
    jr      nz, .notJumping
    
.jumping
    ; Skater Dude is jumping and it is time to change his Y position
    ; Update the position table index
    ld      hl, hSkaterDudePosIndex
    inc     [hl]
    ; Find the new Y position
    ld      a, [hl]
    add     a, a    ; a * 2 (Position, Duration)
    add     a, LOW(xJumpPositionTable)
    ld      l, a
    ASSERT HIGH(xJumpPositionTable.end - 1) == HIGH(xJumpPositionTable)
    ld      h, HIGH(xJumpPositionTable)
    ; Get the new Y position
    ld      a, [hli]    ; a = Y position
    ; 0 signals the end of the table
    and     a, a
    jr      z, .finishedJumping
    ld      e, [hl]     ; e = duration
    
    ; Set the new Y position
    ld      hl, wActorYPosTable
    add     hl, bc
    ld      [hl], a
    ; Set the countdown to the new duration
    ld      a, e
    ldh     [hSkaterDudePosCountdown], a
    jr      .notJumping

.finishedJumping
    ; Set the position table index to -1 to signal not jumping
    ; a = 0
    dec     a
    ldh     [hSkaterDudePosIndex], a
    
.notJumping
    ; Check if the player pressed the jump button
    ldh     a, [hNewKeys]
    bit     PADB_A, a
    jr      z, .noJump
    
    ; Player pressed the A button -> jump
    xor     a, a
    ldh     [hSkaterDudePosIndex], a
    ; Set countdown to 1 to update next frame
    inc     a
    ldh     [hSkaterDudePosCountdown], a
    
    ; Depending on the hit rating, play the appropriate sound effect
    ldh     a, [hLastHitRating]
    ASSERT HIT_BAD < HIT_OK && HIT_PERFECT > HIT_OK
    sub     a, HIT_OK + 1
    ; If Bad or OK, play the wonky jump sound effect
    ld      a, SFX_SKATER_DUDE_JUMP_OK
    jr      c, .notPerfect
    ; If Perfect, play the normal jump sound effect
    ASSERT SFX_SKATER_DUDE_JUMP_PERFECT == SFX_SKATER_DUDE_JUMP_OK + 1
    inc     a
.notPerfect
    ld      e, c    ; e not destroyed by SFX_Play
    ld      b, a    ; b = SFX ID
    call    SFX_Play
    ASSERT HIGH(MAX_NUM_ACTORS) == 0
    ld      b, 0
    ld      c, e
.noSFX
    ld      a, CEL_SKATER_DUDE_JUMPING
    jp      ActorSetAnimationOverride

.noJump
    ; If the player missed this hit (is late enough), they get hit by
    ; the obstacle
    ldh     a, [hLastHit.low]
    cp      a, HIT_MISS_DELAY
    ret     nz
    ldh     a, [hLastHit.high]
    ASSERT HIGH(HIT_MISS_DELAY) == 0
    and     a, a
    ret     nz
    
    ; It's late enough, but did the player already make this hit?
    ldh     a, [hNextHitNumber]
    ld      e, a
    ldh     a, [hLastRatedHitNumber]
    inc     a       ; Comparing with next hit number
    cp      a, e
    ; The player already made this hit -> they're not late
    ret     nc
    
    ; The player missed the hit
    ld      e, c    ; e not destroyed by SFX_Play
    ld      b, SFX_SKATER_DUDE_FALL
    call    SFX_Play
    ASSERT HIGH(MAX_NUM_ACTORS) == 0
    ld      b, 0
    ld      c, e
    
    ; End slo-mo
    ld      a, SKATER_DUDE_NO_SLO_MO
    ldh     [hSloMoCountdown], a
    
    ; "Stop" moving
    ; The background normally scrolls with Skater Dude in place, making
    ; it look like he's the one moving. Since he shouldn't be moving,
    ; move him in the opposite direction the background is moving.
    ld      hl, wActorXSpeedTable
    add     hl, bc
    ; Background scrolls 1 pixel per frame
    ld      [hl], 1 << 3
    
    ; Reset Skater Dude's position for the event of consecutive misses
    ld      hl, wActorXPosTable
    add     hl, bc
    ld      [hl], SKATER_DUDE_X
    
    ; Start the falling animation
    ld      a, CEL_SKATER_DUDE_FALLING
    jp      ActorSetAnimationOverride

.skatingOnscreen
    ; Check if Skater Dude has reached his normal position
    ld      hl, wActorXPosTable
    add     hl, bc
    ld      a, [hl]
    ; Speed is slow enough to simply check for the exact position
    ASSERT SKATER_DUDE_IN_SPEED < 0 && SKATER_DUDE_IN_SPEED >> 3 == -1
    cp      a, SKATER_DUDE_X
    ret     nz
    
    ; Skater Dude has reached his normal position
    ASSERT SKATER_DUDE_X >= NUM_SKATER_DUDE_STATES
    ; State = normal Skater Dude function
    ldh     [hSkaterDudeState], a
    ret

.skateOffscreen
    ld      hl, wActorXSpeedTable
    add     hl, bc
    ld      [hl], SKATER_DUDE_OUT_SPEED
    
    ld      a, SKATER_DUDE_STATE_OUT
    ldh     [hSkaterDudeState], a
    ret

.skatingOffscreen
    ; Check if Skater Dude is finished skating off-screen
    ld      hl, wActorXPosTable
    add     hl, bc
    ld      a, [hl]
    ; Can check for end position with sign bit
    ASSERT SKATER_DUDE_END_X < 0
    ; Normal position is not negative in two's complement
    ASSERT SKATER_DUDE_X & (1 << 7) == 0
    add     a, a    ; Move bit 7 to carry
    ; Not negative (end position is) -> not there yet
    ret     nc
    
    ; Add 1 to check for > instead of >=, shifted to compensate for
    ; double (add a, a)
    cp      a, (SKATER_DUDE_END_X + 1) << 1
    ret     nc
    
    ; Game is over
    ld      a, SKATER_DUDE_STATE_END
    ldh     [hSkaterDudeState], a
    ret

xJumpPositionTable:
    DB SKATER_DUDE_Y - SKATER_DUDE_JUMP_HEIGHT * 1/3, 1
    DB SKATER_DUDE_Y - SKATER_DUDE_JUMP_HEIGHT * 2/3, 1
    DB SKATER_DUDE_Y - SKATER_DUDE_JUMP_HEIGHT, (MUSIC_SKATER_DUDE_SPEED * 4) - (1 + 1 + 1) * 2
    DB SKATER_DUDE_Y - SKATER_DUDE_JUMP_HEIGHT * 2/3, 1
    DB SKATER_DUDE_Y - SKATER_DUDE_JUMP_HEIGHT * 1/3, 1
    DB SKATER_DUDE_Y, 1
    DB 0
.end

SECTION "Skater Dude Obstacle Actor", ROMX

xActorObstacle::
    ld      hl, wActorXSpeedTable
    add     hl, bc
    ; Check if slo-mo status has changed
    ldh     a, [hSloMoCountdown]
    ASSERT SKATER_DUDE_NO_SLO_MO == -1
    inc     a
    jr      z, .noSloMo
    ; Check if slo-mo just started
    ; Add 1 to compensate for the inc
    cp      a, SKATER_DUDE_SLO_MO_DURATION + 1
    jr      c, .noChange
    
    ; In slo-mo -> move slowly
    ld      [hl], OBSTACLE_SLO_MO_SPEED
    
    ; Use slower animation
    ld      a, CEL_OBSTACLE_SLO_MO
    call    ActorSetAnimationOverride
    jr      .noChange
.noSloMo
    ; No longer in slo-mo -> move at the regular speed
    ld      [hl], OBSTACLE_SPEED
    ; Return to the fast animation
    ld      hl, wActorCelOverrideTable
    add     hl, bc
    ld      [hl], ANIMATION_OVERRIDE_NONE
.noChange
    ; Check if the obstacle has gone off-screen
    ld      hl, wActorXPosTable
    add     hl, bc
    ld      a, [hl]
    
    ; Check if the obstacle has not yet come on-screen
    ASSERT LOW(OBSTACLE_X) & (1 << 7) && LOW(SCRN_X) & (1 << 7)
    ASSERT LOW(SCRN_X) < LOW(OBSTACLE_X)
    cp      a, OBSTACLE_X
    ; Haven't come on-screen yet, nothing to do
    ret     nc
    
    ; Check if the obstacle has gone past the right edge of the screen
    cp      a, SCRN_X
    ; Still on-screen, nothing to do
    ret     c
    
    ; Kill this obstacle
    jp      ActorKill
