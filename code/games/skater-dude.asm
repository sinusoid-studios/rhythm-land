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
    ASSERT BANK(xGameSkaterDudeTiles) == BANK(@)
    ld      de, xGameSkaterDudeTiles
    ld      hl, $9000
    ld      bc, xGameSkaterDudeTiles.end - xGameSkaterDudeTiles
    rst     LCDMemcopy
    
    ; Load sprite tiles
    ASSERT BANK(xGameSkaterDudeSpriteTiles) == BANK(@)
    ASSERT xGameSkaterDudeSpriteTiles == xGameSkaterDudeTiles.end
    ld      hl, $8000
    ld      bc, xGameSkaterDudeSpriteTiles.end - xGameSkaterDudeSpriteTiles
    rst     LCDMemcopy
    
    ; Create the Skater Dude actor
    ASSERT BANK(xActorSkaterDudeDefinition) == BANK(@)
    ld      de, xActorSkaterDudeDefinition
    call    ActorsNew
    ld      a, -1
    ldh     [hSkaterDudePosIndex], a
    
    ; Start music
    ld      bc, BANK(Inst_SkaterDude)
    ld      de, Inst_SkaterDude
    call    Music_PrepareInst
    ld      bc, BANK(Music_SkaterDude)
    ld      de, Music_SkaterDude
    call    Music_Play
    
    ; Set up game data
    lb      bc, BANK(xGameSkaterDudeHitTable), BANK(xGameSkaterDudeCueTable)
    ld      de, xGameSkaterDudeCueTable
    ld      hl, xGameSkaterDudeHitTable
    call    EngineInit

.loop
    ; Wait for VBlank
    halt
    ldh     a, [hVBlankFlag]
    and     a, a
    jr      z, .loop
    xor     a, a
    ldh     [hVBlankFlag], a
    
    call    EngineUpdate
    call    ActorsUpdate
    
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

xGameSkaterDudeTiles:
    INCBIN "res/skater-dude/background.bg.2bpp"
.end

xGameSkaterDudeSpriteTiles:
    INCBIN "res/skater-dude/skater-dude.obj.2bpp", 16 * 2
.end

xGameSkaterDudeMap:
    INCBIN "res/skater-dude/background.bg.tilemap"
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
    ASSERT HIGH(JumpPositionTable.end - 1) == HIGH(JumpPositionTable)
    ld      h, HIGH(JumpPositionTable)
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
