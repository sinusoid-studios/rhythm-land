INCLUDE "constants/hardware.inc"
INCLUDE "constants/actors.inc"
INCLUDE "constants/games.inc"
INCLUDE "constants/title.inc"

SECTION UNION "Game Variables", HRAM

; Current position in the title screen scroll table
hScrollIndex:
; Number of frames left in a flash
hFlashCountdown:
    DS 1

SECTION "Title Screen Setup", ROM0

SetupTitleScreen::
    ; Start below the screen and scroll up
    xor     a, a
    ldh     [hScrollIndex], a
    ; a = 0
    ldh     [hSCX], a
    ld      a, LOW(-SCRN_Y)
    ldh     [hSCY], a
    
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
    
    ; Load sprite tiles
    ld      de, SpriteTilesTitle
    ld      hl, $8000
    ld      bc, SpriteTilesTitle.end - SpriteTilesTitle
    rst     LCDMemcopy
    
    ; Load background map
    ld      de, MapTitle
    ld      hl, _SCRN0
    call    LCDMemcopyMap
    
    ; Create star actors
    ld      de, ActorStarDefinitions
    ld      a, NUM_STARS
    ldh     [hScratch1], a
.starLoop
    call    ActorsNew
    ldh     a, [hScratch1]
    dec     a
    ldh     [hScratch1], a
    jr      nz, .starLoop
    
    ; Prepare music
    ld      c, BANK(Inst_Title)
    ld      de, Inst_Title
    jp      Music_PrepareInst

SECTION "Title Screen Large Star Actor Definitions", ROM0

ActorStarDefinitions:
    ; Large Star 1
    DB ACTOR_LARGE_STAR_1
    DB 27, -2
    DB 0, 0
    ; Large Star 2
    DB ACTOR_LARGE_STAR_2
    DB 113, 0
    DB 0, 0
    ; Large Star 3
    DB ACTOR_LARGE_STAR_3
    DB 8, 104
    DB 0, 0
    ; Large Star 4
    DB ACTOR_LARGE_STAR_4
    DB 129, 104
    DB 0, 0
    ; Small Star 1
    DB ACTOR_SMALL_STAR_1
    DB 8, 24
    DB 0, 0
    ; Small Star 2
    DB ACTOR_SMALL_STAR_2
    DB 56, 24
    DB 0, 0
    ; Small Star 3
    DB ACTOR_SMALL_STAR_3
    DB 96, 8
    DB 0, 0
    ; Small Star 4
    DB ACTOR_SMALL_STAR_4
    DB 144, 32
    DB 0, 0
    ; Small Star 5
    DB ACTOR_SMALL_STAR_5
    DB 8, 88
    DB 0, 0
    ; Small Star 6
    DB ACTOR_SMALL_STAR_6
    DB 40, 128
    DB 0, 0
    ; Small Star 7
    DB ACTOR_SMALL_STAR_7
    DB 120, 136
    DB 0, 0

SECTION "Title Screen Background Tiles", ROM0

BackgroundTilesTitle9000:
    INCBIN "res/title/background.bg.2bpp", 0, 128 * 16
.end
BackgroundTilesTitle8800:
    INCBIN "res/title/background.bg.2bpp", 128 * 16
.end

SECTION "Title Screen Sprite Tiles", ROM0

SpriteTilesTitle:
    ; Remove the first 2 tiles which are blank on purpose to get rid of
    ; any blank objects in the image
    INCBIN "res/title/stars-large.obj.2bpp", 16 * 2
    INCBIN "res/title/stars-small.obj.2bpp"
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
    
    ld      hl, TitleScrollPosTable
.scrollLoop
    rst     WaitVBlank
    ; Move to the next scroll position
    ld      a, [hli]
    ASSERT TITLE_SCROLL_END_POS == 0
    and     a, a
    ldh     [hSCY], a
    jr      z, .loop
    jr      .scrollLoop
    
.loop
    rst     WaitVBlank
    
    call    ActorsUpdate
    
    ldh     a, [hFlashCountdown]
    and     a, a
    jr      z, .checkSync
    ; Update flash
    dec     a
    ldh     [hFlashCountdown], a
    jr      nz, .checkSync
    ; Flash is over -> reset to normal palette
    ld      a, %11100100
    ldh     [hBGP], a
.checkSync
    ld      a, [wMusicSyncData]
    ASSERT SYNC_TITLE_BEAT == 1
    dec     a
    jr      z, .beat
    ASSERT SYNC_TITLE_FLASH == 2
    dec     a
    jr      nz, .noSyncData
    ; Flash
    ld      a, %10010000    ; One shade lighter than normal
    ldh     [hBGP], a
    ; Reset countdown to flash duration
    ld      a, TITLE_FLASH_DURATION
    ldh     [hFlashCountdown], a
    jr      .noSyncData
.beat
    ; TODO: Fancy bouncing
.noSyncData
    ldh     a, [hNewKeys]
    and     a, PADF_A | PADF_START
    jr      z, .loop
    
    ; Move to game select screen
    ld      a, ID_GAME_SELECT
    jp      Transition

SECTION "Title Screen Actor", ROMX

xActorTitle::
    ; TODO: Bounce
    ret
