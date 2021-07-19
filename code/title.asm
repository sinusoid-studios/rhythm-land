INCLUDE "defines.inc"

SECTION "Title Screen Setup", ROM0

SetupTitleScreen::
    ; Load background tiles
    ld      de, BackgroundTilesTitle9000
    ld      hl, $9000
    ld      bc, BackgroundTilesTitle9000.end - BackgroundTilesTitle9000
    rst     LCDMemcopy
    ASSERT BackgroundTilesTitle8800 == BackgroundTilesTitle9000.end
    ; de = BackgroundTilesTitle8800
    ld      hl, $8800
    ld      bc, BackgroundTilesTitle8800.end - BackgroundTilesTitle8800
    rst     LCDMemcopy
    
    ; Load background map
    ld      de, MapTitle
    ld      hl, _SCRN0
    call    LCDMemcopyMap
    
    ; Prepare music
    ld      c, BANK(Inst_Title)
    ld      de, Inst_Title
    jp      Music_PrepareInst

SECTION "Title Screen Background Tiles", ROM0

BackgroundTilesTitle9000:
    INCBIN "res/title/background.bg.2bpp", 0, 128 * 16
.end
BackgroundTilesTitle8800:
    INCBIN "res/title/background.bg.2bpp", 128 * 16
.end

SECTION "Title Screen Background Map", ROM0

MapTitle:
    INCBIN "res/title/background.bg.tilemap"

SECTION "Title Screen Loop", ROM0

TitleScreen::
    ; Start the music
    ld      c, BANK(Music_Title)
    ld      de, Music_Title
    call    Music_Play
    
.loop
    rst     WaitVBlank
    
    ld      a, [wMusicSyncData]
    ASSERT SYNC_TITLE_BEAT == 1
    dec     a
    jr      nz, .noSyncData
    
    ; TODO: Recreate the fun scaling effect
    ; For now just invert the background palette
    ldh     a, [rBGP]
    cpl
    ldh     [rBGP], a
    
.noSyncData
    ldh     a, [hNewKeys]
    and     a, PADF_A | PADF_START
    jr      z, .loop
    
    ; Move to game select screen
    ld      a, ID_GAME_SELECT
    jp      Transition
