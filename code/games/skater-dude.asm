INCLUDE "constants/hardware.inc"
INCLUDE "constants/engine.inc"
INCLUDE "constants/actors.inc"
INCLUDE "constants/sfx.inc"
INCLUDE "constants/screens.inc"
INCLUDE "constants/interrupts.inc"
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

; Storage for the current positions of the different sections of the
; background
hSectionMapXPosStart:
hBuildingMapXPos:
.low
    DS 1
.high
    DS 1
hRoadMapXPos:
.low
    DS 1
.high
    DS 1
hGrassMapXPos:
.low
    DS 1
.high
    DS 1

hRoadSCX:
    DS 1
hGrassSCX:
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
    xor     a, a
    ld      [hli], a
    ld      [hli], a
    ASSERT hMapTileYPos == hMapXPos + 2
    ld      [hli], a
    ASSERT hMapSCX == hMapTileYPos + 1
    ld      [hli], a
    ASSERT hMapSCY == hMapSCX + 1
    ld      [hli], a
    ASSERT hMapUpdateHeight == hMapSCY + 1
    ; Draw the entire visible map to start
    ld      [hl], SCRN_Y_B
    
    ; Initialize section map positions
    ld      l, LOW(hSectionMapXPosStart)
    ld      [hli], a
    ld      [hli], a
    ld      [hli], a
    ld      [hli], a
    ld      [hli], a
    ld      [hli], a
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

SECTION FRAGMENT "LYC Value Table", ROM0, ALIGN[8]

LYCTableSkaterDude:
    DB 0
    DB MAP_SKATER_DUDE_ROAD_Y * 8 - 1
    DB MAP_SKATER_DUDE_GRASS_Y * 8 - 1
    DB LYC_RESET

SECTION "Skater Dude Game Extra LYC Interrupt Handler", ROM0

LYCHandlerSkaterDude::
    ; Set appropriate map section's X scroll value
    ldh     a, [rLYC]
    cp      a, MAP_SKATER_DUDE_ROAD_Y * 8 - 1
    jr      z, .road
    ; Grass section
    ldh     a, [hGrassSCX]
    ; Z still unset
    DB      $CA     ; jp z, a16 to consume the next 2 bytes
.road
    ; Road section
    ldh     a, [hRoadSCX]
    
    ; Set SCX in/after HBlank
    ld      b, a
.waitHBlank
    ldh     a, [rSTAT]
    ASSERT STATF_HBL == 0
    and     a, STAT_MODE_MASK
    jr      nz, .waitHBlank
    
    ld      a, b
    ldh     [rSCX], a
    ret

SECTION "Skater Dude Game Loop", ROMX

xGameSkaterDude::
    ; Set up extra LYC interrupts
    ASSERT LYCTableSkaterDude - STARTOF("LYC Value Table") == 0
    xor     a, a
    ldh     [hLYCIndex], a
    ldh     [hLYCResetIndex], a
    
.loop
    rst     WaitVBlank
    
    ldh     a, [hTransitionState]
    ASSERT TRANSITION_STATE_OFF == 0
    and     a, a
    jr      z, .noTransition
    
    call    TransitionUpdate
    call    .scroll
    
    ldh     a, [hTransitionState]
    ASSERT TRANSITION_STATE_OFF == 0
    and     a, a
    jr      nz, .loop
    
    ; Start music
    ld      c, BANK(Music_SkaterDude)
    ld      de, Music_SkaterDude
    call    Music_Play
    jr      .loop

.noTransition
    call    EngineUpdate
    
    call    ActorsUpdate
    ldh     a, [hSloMoCountdown]
    ASSERT SKATER_DUDE_NO_SLO_MO == -1
    inc     a
    call    z, .scroll
    
    ; If the game is over, go to the overall rating screen
    ldh     a, [hSkaterDudeState]
    cp      a, SKATER_DUDE_STATE_END
    jr      z, .finished
    
    ld      hl, hSloMoCountdown
    ld      a, [hl]
    ASSERT SKATER_DUDE_NO_SLO_MO == -1
    inc     a
    jr      z, .loop
    dec     [hl]
    jr      .loop

.finished
    ld      a, SCREEN_RATING
    call    TransitionStart
    jr      .loop

.scroll
    ; Scroll each section of the background map
    
    ; Scroll the grass
    ldh     a, [hGrassMapXPos.low]
    ldh     [hMapXPos.low], a
    ldh     a, [hGrassMapXPos.high]
    ldh     [hMapXPos.high], a
    ldh     a, [hGrassSCX]
    ldh     [hMapSCX], a
    ld      a, MAP_SKATER_DUDE_GRASS_Y
    ldh     [hMapTileYPos], a
    ld      a, MAP_SKATER_DUDE_GRASS_Y * 8
    ldh     [hMapSCY], a
    ld      a, MAP_SKATER_DUDE_GRASS_HEIGHT
    ldh     [hMapUpdateHeight], a
    ; Grass scrolls 1 pixel every 3/4 frames and 2 pixels every 1/4 frames
    ldh     a, [hFrameCounter]
    and     a, 3        ; a = 0-3
    ld      d, 2
    jr      z, .grass2  ; Scroll 2 pixels if a = 0
    dec     d           ; Scroll 1 pixel otherwise
.grass2
    call    MapScrollLeft
    ; Save new position
    ldh     a, [hMapXPos.low]
    ldh     [hGrassMapXPos.low], a
    ldh     a, [hMapXPos.high]
    ldh     [hGrassMapXPos.high], a
    ldh     a, [hMapSCX]
    ldh     [hGrassSCX], a
    
    ; Scroll the road
    ldh     a, [hRoadMapXPos.low]
    ldh     [hMapXPos.low], a
    ldh     a, [hRoadMapXPos.high]
    ldh     [hMapXPos.high], a
    ldh     a, [hRoadSCX]
    ldh     [hMapSCX], a
    ld      a, MAP_SKATER_DUDE_ROAD_Y
    ldh     [hMapTileYPos], a
    ld      a, MAP_SKATER_DUDE_ROAD_Y * 8
    ldh     [hMapSCY], a
    ld      a, MAP_SKATER_DUDE_ROAD_HEIGHT
    ldh     [hMapUpdateHeight], a
    ; Road scrolls 1 pixel every frame
    ld      d, 1
    call    MapScrollLeft
    ; Save new position
    ldh     a, [hMapXPos.low]
    ldh     [hRoadMapXPos.low], a
    ldh     a, [hMapXPos.high]
    ldh     [hRoadMapXPos.high], a
    ldh     a, [hMapSCX]
    ldh     [hRoadSCX], a
    
    ; Scroll the buildings
    ; Buildings scroll 1 pixel every 3/4 frames
    ldh     a, [hFrameCounter]
    and     a, 3    ; a = 0-3
    ret     z       ; Only scroll if a = 1-3
    
    ldh     a, [hBuildingMapXPos.low]
    ldh     [hMapXPos.low], a
    ldh     a, [hBuildingMapXPos.high]
    ldh     [hMapXPos.high], a
    ldh     a, [hSCX]
    ldh     [hMapSCX], a
    ld      a, MAP_SKATER_DUDE_BUILDING_Y
    ldh     [hMapTileYPos], a
    ld      a, MAP_SKATER_DUDE_BUILDING_Y * 8
    ldh     [hMapSCY], a
    ld      a, MAP_SKATER_DUDE_BUILDING_HEIGHT
    ldh     [hMapUpdateHeight], a
    ld      d, 1
    call    MapScrollLeft
    ; Save new position
    ldh     a, [hMapXPos.low]
    ldh     [hBuildingMapXPos.low], a
    ldh     a, [hMapXPos.high]
    ldh     [hBuildingMapXPos.high], a
    ldh     a, [hMapSCX]
    ldh     [hSCX], a
    ret

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
    ASSERT OBSTACLE_COUNT == 3
    and     a, 3
    cp      a, OBSTACLE_COUNT
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
    jr      nc, .updateJump
    
.moving
    ; Skater Dude is either skating or jumping -> "move"
    ld      hl, wActorXSpeedTable
    add     hl, bc
    ld      [hl], 0
    ; Make sure the position is correct after falling
    ld      hl, wActorXPosTable
    add     hl, bc
    ld      [hl], SKATER_DUDE_X
    
.updateJump
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
    ld      b, a    ; b = SFX ID
    call    SFX_Play
    ASSERT HIGH(MAX_ACTOR_COUNT) == HIGH(0)
    ld      b, 0
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
    
    ; It's late enough, but did the player already jump successfully (OK
    ; or Perfect hit)?
    ldh     a, [hNextHitNumber]
    ld      e, a
    ldh     a, [hLastRatedHitNumber]
    inc     a       ; Comparing with next hit number
    cp      a, e
    ; The player already made this hit -> they're not late
    ret     nc
    
    ; The player missed the hit
    ld      b, SFX_SKATER_DUDE_FALL
    call    SFX_Play
    ASSERT HIGH(MAX_ACTOR_COUNT) == HIGH(0)
    ld      b, 0
    
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
    jp      nz, .updateJump
    
    ; Skater Dude has reached his normal position
    ASSERT SKATER_DUDE_X >= SKATER_DUDE_STATE_COUNT
    ; State = normal Skater Dude function
    ldh     [hSkaterDudeState], a
    jp      .updateJump

.skateOffscreen
    ld      hl, wActorXSpeedTable
    add     hl, bc
    ld      [hl], SKATER_DUDE_OUT_SPEED
    
    ld      a, SKATER_DUDE_STATE_OUT
    ldh     [hSkaterDudeState], a
    jp      .updateJump

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
    jp      nc, .updateJump
    
    ; Add 1 to check for > instead of >=, shifted to compensate for
    ; double (add a, a)
    cp      a, (SKATER_DUDE_END_X + 1) << 1
    jp      nc, .updateJump
    
    ; Game is over
    ld      a, SKATER_DUDE_STATE_END
    ldh     [hSkaterDudeState], a
    jp      .updateJump

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
