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
    INCBIN "res/skater-dude/background.2bpp"
.end

xGameSkaterDudeSpriteTiles:
    INCBIN "res/skater-dude/sprites.2bpp"
.end

xGameSkaterDudeMap:
    INCBIN "res/skater-dude/background.tilemap"
.end

SECTION "Skater Dude Warning Cue", ROMX

xCueSkaterDudeWarning::
    ldh     a, [rBGP]
    cpl
    ldh     [rBGP], a
    ret
