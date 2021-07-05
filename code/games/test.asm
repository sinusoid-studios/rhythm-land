INCLUDE "defines.inc"

SECTION "Test Game", ROMX

xGameTest::
    ; Start music
    ld      bc, BANK(Inst_FileSelect)
    ld      de, Inst_FileSelect
    call    Music_PrepareInst
    ld      bc, BANK(Music_FileSelect)
    ld      de, Music_FileSelect
    call    Music_Play
    
    ; Set up game data
    ld      b, BANK(xGameTestCueTable)
    ld      de, xGameTestCueTable
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
    
    jr      .loop

SECTION "Test Cue", ROMX

xCueTest::
    ; Play a placeholder sound effect
    ld      b, SFX_TEST
    jp      SFX_Play
