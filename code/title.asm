INCLUDE "defines.inc"

SECTION "Title Screen Setup", ROM0

SetupTitleScreen::
    ; Start music
    ld      c, BANK(Inst_Title)
    ld      de, Inst_Title
    call    Music_PrepareInst
    ld      c, BANK(Music_Title)
    ld      de, Music_Title
    jp      Music_Play

SECTION "Title Screen Loop", ROM0

TitleScreen::
    rst     WaitVBlank
    
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
    jr      z, TitleScreen
    
    ; Move to game select screen
    ld      a, ID_GAME_SELECT
    jp      Transition
