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
    
    ld      hl, _SCRN0 + (SCRN_X_B - 2)
    ld      a, [wMusicSyncData]
    call    DrawHex
    
    ld      a, [wMusicSyncData]
    and     a, a
    jr      z, .noData
    
    ld      hl, _SCRN0 + (1 * SCRN_VX_B) + (SCRN_X_B - 2)
    ld      a, [wMusicSyncData]
    call    DrawHex
    
    ldh     a, [rBGP]
    cpl
    ldh     [rBGP], a
    
    xor     a, a
    ld      [wMusicSyncData], a
    
.noData
    ld      hl, _SCRN0
    ld      de, SCRN_VX_B - (2 * 2 + 1)
    
    ldh     a, [hLastHit]
    call    DrawHex
    inc     l
    ldh     a, [hNextHit]
    call    DrawHex
    
    add     hl, de
    
    ldh     a, [hLastHitKeys]
    call    DrawHex
    inc     l
    ldh     a, [hNextHitKeys]
    call    DrawHex
    
    add     hl, de
    
    ldh     a, [hHitPerfectCount]
    call    DrawHex
    inc     l
    ldh     a, [hHitOkCount]
    call    DrawHex
    inc     l
    ldh     a, [hHitBadCount]
    call    DrawHex
    
    ldh     a, [hLastHit]
    and     a, a
    jr      nz, .loop
    
    ld      b, SFX_BEEP
    call    SFX_Play
    jr      .loop

; @param    a   Value to draw
; @param    hl  Pointer to destination on map
DrawHex:
    ld      b, a
.waitVRAM
    ldh     a, [rSTAT]
    and     a, STATF_BUSY
    jr      nz, .waitVRAM
    
    ld      a, b        ; 1 cycle
    swap    a           ; 2 cycles
    and     a, $0F      ; 2 cycles
    ld      [hli], a    ; 2 cycles
    ld      a, b        ; 1 cycle
    and     a, $0F      ; 2 cycles
    ld      [hli], a    ; 2 cycles
    ; Total 12 cycles
    ret

SECTION "Test Cue", ROMX

xCueTest::
    ; Play a placeholder sound effect
    ld      b, SFX_TEST_CUE
    jp      SFX_Play
