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

SECTION "Skater Dude Game", ROMX

xGameSkaterDude::
    ld      a, 60 * 2
    ldh     [hEndDelay], a
    
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
    
    ; Start music
    ld      c, BANK(Inst_SkaterDude)
    ld      de, Inst_SkaterDude
    call    Music_PrepareInst
    ld      c, BANK(Music_SkaterDude)
    ld      de, Music_SkaterDude
    call    Music_Play
    
    ; Set up game data
    ld      c, BANK(xHitTableSkaterDude)
    ld      hl, xHitTableSkaterDude
    call    EngineInit

.loop
    rst     WaitVBlank
    
    call    EngineUpdate
    call    ActorsUpdate
    call    MapScrollLeft
    
    ldh     a, [hHitTableBank]
    and     a, a
    jr      nz, :+
    
    ld      hl, hEndDelay
    dec     [hl]
    ; Finished, go to the rating screen
    jp      z, RatingScreen
    
:
    ldh     a, [hNewKeys]
    bit     PADB_A, a
    jr      z, .loop
    
    ; Player pressed A, play jump sound effect
    ld      b, SFX_SKATER_DUDE_JUMP
    call    SFX_Play
    jr      .loop

xBackgroundTilesSkaterDude:
    INCBIN "res/skater-dude/background.bg.2bpp"
.end

xSpriteTilesSkaterDude:
    ; Remove the first 2 tiles which are blank on purpose to get rid of
    ; any blank objects in the image
    INCBIN "res/skater-dude/skater-dude.obj.2bpp", 16 * 2
    INCBIN "res/skater-dude/skateboard.obj.2bpp", 16 * 2
.end

xActorSkaterDudeDefinition:
    DB ACTOR_SKATER_DUDE, SKATER_DUDE_X, SKATER_DUDE_GROUND_Y

SECTION "Skater Dude Warning Cue", ROMX

xCueSkaterDudeWarning::
    ldh     a, [rBGP]
    cpl
    ldh     [rBGP], a
    ret

SECTION "Skater Dude Actor", ROMX

xActorSkaterDude::
    ldh     a, [hSkaterDudePosIndex]
    inc     a
    jr      z, .notJumping
    
    ld      hl, hSkaterDudePosCountdown
    dec     [hl]
    jr      nz, .notJumping
    
    ASSERT hSkaterDudePosIndex == hSkaterDudePosCountdown - 1
    dec     l
    inc     [hl]
    ld      a, [hl]
    add     a, a
    add     a, LOW(JumpPositionTable)
    ld      l, a
    adc     a, HIGH(JumpPositionTable)
    sub     a, l
    ld      h, a
    ld      a, [hli]
    inc     a
    jr      z, .finishedJumping
    dec     a       ; Undo inc
    ld      e, [hl]
    
    ld      hl, wActorYPosTable
    add     hl, bc
    ld      [hl], a
    ld      a, e
    ldh     [hSkaterDudePosCountdown], a
    jr      .notJumping

.finishedJumping
    ld      a, -1
    ldh     [hSkaterDudePosIndex], a
    
.notJumping
    ldh     a, [hNewKeys]
    bit     PADB_A, a
    ret     z
    
    ; Player pressed the A button -> jump
    xor     a, a
    ldh     [hSkaterDudePosIndex], a
    inc     a
    ldh     [hSkaterDudePosCountdown], a
    
    ld      hl, wActorCelTable
    add     hl, bc
    ld      [hl], CEL_SKATER_DUDE_JUMPING
    jp      ActorsResetCelCountdown

JumpPositionTable:
    DB SKATER_DUDE_GROUND_Y - SKATER_DUDE_JUMP_HEIGHT * 1/3, 1
    DB SKATER_DUDE_GROUND_Y - SKATER_DUDE_JUMP_HEIGHT * 2/3, 1
    DB SKATER_DUDE_GROUND_Y - SKATER_DUDE_JUMP_HEIGHT, (MUSIC_SKATER_DUDE_SPEED * 4) - (1 + 1 + 1) * 2
    DB SKATER_DUDE_GROUND_Y - SKATER_DUDE_JUMP_HEIGHT * 2/3, 1
    DB SKATER_DUDE_GROUND_Y - SKATER_DUDE_JUMP_HEIGHT * 1/3, 1
    DB SKATER_DUDE_GROUND_Y, 1
    DB -1
.end
