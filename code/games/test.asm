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
    lb      bc, BANK(xGameTestHitTable), BANK(xGameTestCueTable)
    ld      de, xGameTestCueTable
    ld      hl, xGameTestHitTable
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
    
    ldh     a, [hLastHit]
    and     a, a
    jr      nz, .loop
    
    ld      b, SFX_BEEP
    call    SFX_Play
    jr      .loop

SECTION "Test Cue", ROMX

xCueTest::
    ; Play a placeholder sound effect
    ld      b, SFX_TEST_CUE
    jp      SFX_Play
