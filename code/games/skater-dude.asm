INCLUDE "defines.inc"

SECTION UNION "Game Variables", HRAM

; Delay after the game is finished to allow for a late last hit
hEndDelay:
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
    INCBIN "res/skater-dude/skater-dude.obj.2bpp"
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
    ldh     a, [hNewKeys]
    bit     PADB_A, a
    jr      z, .noJump
    
    ; Player pressed the A button -> jump
    ld      hl, wActorYSpeedTable
    add     hl, bc
    ld      [hl], SKATER_DUDE_JUMP_SPEED
    ret

.noJump
    ; Apply gravity unless already on the ground
    ld      hl, wActorYPosTable
    add     hl, bc
    ld      a, [hl]
    cp      a, SKATER_DUDE_GROUND_Y
    jr      nc, .onGround
    
    ; Currently in the air -> fall
    ld      hl, wActorYSpeedTable
    add     hl, bc
    dec     [hl]
    ret

.onGround
    ld      [hl], SKATER_DUDE_GROUND_Y
    ld      hl, wActorYSpeedTable
    add     hl, bc
    ld      [hl], 0
    ret
