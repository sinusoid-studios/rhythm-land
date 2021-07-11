INCLUDE "defines.inc"

SECTION "Title Screen", ROM0

TitleScreen::
    ; Start music
    ld      bc, BANK(Inst_Title)
    ld      de, Inst_Title
    call    Music_PrepareInst
    ld      bc, BANK(Music_Title)
    ld      de, Music_Title
    call    Music_Play
    
.loop
    ; Wait for VBlank
    halt
    ldh     a, [hVBlankFlag]
    and     a, a
    jr      z, .loop
    xor     a, a
    ldh     [hVBlankFlag], a
    
    ld      a, [wMusicSyncData]
    and     a, a
    jr      z, .noSyncData
    
    ASSERT SYNC_TITLE_BEAT == 1
    dec     a
    jr      nz, .noSyncData
    
    ; TODO: Recreate the fun scaling effect
    ; For now just invert the background palette
    ldh     a, [rBGP]
    cpl
    ldh     [rBGP], a
    
    ; Reset sync data
    xor     a, a
    ld      [wMusicSyncData], a
    
.noSyncData
    ldh     a, [hNewKeys]
    and     a, PADF_A | PADF_START
    jr      z, .loop
    
    ; Move to game select screen
    jp      GameSelect
