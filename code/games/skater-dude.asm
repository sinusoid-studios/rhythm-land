INCLUDE "defines.inc"

SECTION "Skater Dude Game", ROMX

xGameSkaterDude::
    ; Load tiles
    ld      de, xGameSkaterDudeTiles
    ld      hl, $9000
    ld      bc, xGameSkaterDudeTiles.end - xGameSkaterDudeTiles
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
    
    ldh     a, [hLastHit.low]
    and     a, a
    jr      nz, .loop
    ldh     a, [hLastHit.high]
    and     a, a
    jr      nz, .loop
    
    ld      b, SFX_SKATER_DUDE_JUMP
    call    SFX_Play
    jr      .loop

xGameSkaterDudeTiles:
    INCBIN "res/skater-dude/skater-dude.2bpp"
.end::

xGameSkaterDudeMap:
    INCBIN "res/skater-dude/skater-dude.tilemap"
.end::

SECTION "Skater Dude Warning Cue", ROMX

xCueSkaterDudeWarning::
    ldh     a, [rBGP]
    cpl
    ldh     [rBGP], a
    ret
