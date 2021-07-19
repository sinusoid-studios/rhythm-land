INCLUDE "defines.inc"

SECTION UNION "Game Variables", HRAM

; Delay after the game is finished to allow for a late last hit
hEndDelay:
    DS 1

; Index into Skater Dude's jump position table
hSkaterDudePosIndex:
    DS 1
hSkaterDudePosCountdown:
    DS 1

hSloMoCountdown::
    DS 1

SECTION "Skater Dude Game Setup", ROMX

xGameSetupSkaterDude::
    ld      a, 60 * 2
    ldh     [hEndDelay], a
    
    ; Initially no slo-mo
    xor     a, a
    ldh     [hSloMoCountdown], a
    
    ; Load background tiles
    ASSERT BANK(xBackgroundTilesSkaterDude) == BANK(@)
    ld      de, xBackgroundTilesSkaterDude
    ld      hl, $9000
    ld      bc, xBackgroundTilesSkaterDude.end - xBackgroundTilesSkaterDude
    rst     LCDMemcopy
    
    ; Load sprite tiles
    ASSERT BANK(xSpriteTilesSkaterDude) == BANK(@)
    ASSERT xSpriteTilesSkaterDude == xBackgroundTilesSkaterDude.end
    ld      hl, $8000
    ld      bc, xSpriteTilesSkaterDude.end - xSpriteTilesSkaterDude
    rst     LCDMemcopy
    
    ; Set up the background map
    ld      hl, hMapWidth
    ld      [hl], MAP_SKATER_DUDE_WIDTH
    ASSERT hMapHeight == hMapWidth + 1
    inc     l
    ld      [hl], MAP_SKATER_DUDE_HEIGHT
    ASSERT hMapBank == hMapHeight + 1
    inc     l
    ld      [hl], BANK(xMapSkaterDude)
    ASSERT hMapPointer == hMapBank + 1
    inc     l
    ld      [hl], LOW(xMapSkaterDude)
    inc     l
    ld      [hl], HIGH(xMapSkaterDude)
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
    
    ; Create the Skater Dude actor
    ASSERT BANK(xActorSkaterDudeDefinition) == BANK(@)
    ld      de, xActorSkaterDudeDefinition
    call    ActorsNew
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

xBackgroundTilesSkaterDude:
    INCBIN "res/skater-dude/background.bg.2bpp"
.end

xSpriteTilesSkaterDude:
    ; Remove the first 2 tiles which are blank on purpose to get rid of
    ; any blank objects in the image
    INCBIN "res/skater-dude/skater-dude.obj.2bpp", 16 * 2
    INCBIN "res/skater-dude/skateboard.obj.2bpp", 16 * 2
    INCBIN "res/skater-dude/danger-alert.obj.2bpp"
    INCBIN "res/skater-dude/car.obj.2bpp", 16 * 2
.end

xActorSkaterDudeDefinition:
    DB ACTOR_SKATER_DUDE
    DB SKATER_DUDE_X, SKATER_DUDE_Y
    DB 0, 0

SECTION "Skater Dude Game Background Map", ROMX

xMapSkaterDude:
    INCBIN "res/skater-dude/background.bg.tilemap"

SECTION "Skater Dude Game Loop", ROMX

xGameSkaterDude::
    ; Start music
    ld      c, BANK(Music_SkaterDude)
    ld      de, Music_SkaterDude
    call    Music_Play
    
.loop
    rst     WaitVBlank
    
    call    EngineUpdate
    
    call    ActorsUpdate
    ldh     a, [hSloMoCountdown]
    and     a, a
    jr      nz, .noScroll
    call    MapScrollLeft
.noScroll
    
    ld      hl, hSloMoCountdown
    ld      a, [hl]
    and     a, a
    jr      z, .noSloMo
    dec     [hl]
.noSloMo
    
    ldh     a, [hHitTableBank]
    and     a, a
    jr      nz, .loop
    
    ld      hl, hEndDelay
    dec     [hl]
    ; Finished, go to the rating screen
    jp      z, RatingScreen
    jr      .loop

SECTION "Skater Dude Danger Alert Cue", ROMX

xCueDangerAlert::
    ; Create a Danger Alert actor
    ASSERT BANK(xActorDangerAlertDefinition) == BANK(@)
    ld      de, xActorDangerAlertDefinition
    jp      ActorsNew

xActorDangerAlertDefinition:
    DB ACTOR_DANGER_ALERT
    DB DANGER_ALERT_X, DANGER_ALERT_Y
    DB 0, 0

SECTION "Skater Dude Obstacle Cue", ROMX

xCueObstacle::
    ; Create an obstacle
    ; TODO: Add more obstacle types and choose one randomly
    ASSERT NUM_OBSTACLES == 1
    ASSERT BANK(xObstacleDefinitions) == BANK(@)
    ld      de, xObstacleDefinitions
    jp      ActorsNew

xObstacleDefinitions:
    ; Car
    DB ACTOR_CAR
    DB OBSTACLE_X, OBSTACLE_Y
    DB OBSTACLE_SPEED, 0
.end

SECTION "Skater DUde Slo-Mo Cue", ROMX

xCueSloMo::
    ; Start slo-mo
    ld      a, SKATER_DUDE_SLO_MO_DURATION
    ldh     [hSloMoCountdown], a
    ret

SECTION "Skater Dude Actor", ROMX

xActorSkaterDude::
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
    and     a, a
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
    adc     a, HIGH(xJumpPositionTable)
    sub     a, l
    ld      h, a
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
    jp      ActorsSetAnimationOverride

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
    xor     a, a
    ldh     [hSloMoCountdown], a
    
    ; "Stop" moving
    ; The background normally scrolls with Skater Dude in place, making
    ; it look like he's the one moving. Since he shouldn't be moving,
    ; move him in the opposite direction the background is moving.
    ld      hl, wActorXSpeedTable
    add     hl, bc
    ; Background scrolls 1 pixel per frame
    ld      [hl], 1 << 3
    
    ; Start the falling animation
    ld      a, CEL_SKATER_DUDE_FALLING
    jp      ActorsSetAnimationOverride

xJumpPositionTable:
    DB SKATER_DUDE_Y - SKATER_DUDE_JUMP_HEIGHT * 1/3, 1
    DB SKATER_DUDE_Y - SKATER_DUDE_JUMP_HEIGHT * 2/3, 1
    DB SKATER_DUDE_Y - SKATER_DUDE_JUMP_HEIGHT, (MUSIC_SKATER_DUDE_SPEED * 4) - (1 + 1 + 1) * 2
    DB SKATER_DUDE_Y - SKATER_DUDE_JUMP_HEIGHT * 2/3, 1
    DB SKATER_DUDE_Y - SKATER_DUDE_JUMP_HEIGHT * 1/3, 1
    DB SKATER_DUDE_Y, 1
    DB 0
.end
