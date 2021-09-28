INCLUDE "constants/hardware.inc"
INCLUDE "constants/other-hardware.inc"
INCLUDE "constants/actors.inc"
INCLUDE "constants/screens.inc"
INCLUDE "constants/title.inc"
INCLUDE "constants/transition.inc"

SECTION UNION "Game Variables", HRAM

; Number of frames left in a flash
hFlashCountdown:
    DS 1

SECTION "Title Screen Setup", ROM0

ScreenSetupTitle::
    ; Set palettes
    ld      a, TITLE_BGP
    ldh     [hBGP], a
    ld      a, TITLE_OBP0
    ldh     [hOBP0], a
    
    ; Set appropriate LCDC flags
    ld      a, LCDCF_ON | LCDCF_BG8800 | LCDCF_BG9800 | LCDCF_BGON | LCDCF_OBJ16 | LCDCF_OBJON
    ldh     [hLCDC], a
    
    ; Reset flash countdown
    xor     a, a
    ldh     [hFlashCountdown], a
    
    ; Start below the screen and scroll up
    ; a = 0
    ldh     [hSCX], a
    ld      a, TITLE_SCROLL_START_POS
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
    ld      c, SCRN_Y_B
    call    LCDMemcopyMap
    
    ; No tile streaming on this screen
    xor     a, a
    ldh     [hTileStreamingEnable], a
    
    ; Create star actors
    ld      de, ActorStarDefinitions
    ld      a, STAR_COUNT
    ldh     [hScratch1], a
.starLoop
    call    ActorNew
    ldh     a, [hScratch1]
    dec     a
    ldh     [hScratch1], a
    jr      nz, .starLoop
    
    ret

SECTION "Title Screen Large Star Actor Definitions", ROM0

ActorStarDefinitions:
    ; Large Star 1
    DB ACTOR_LARGE_STAR_1
    DB 20, -4
    DB 0.4f, 0.7f
    ; Large Star 2
    DB ACTOR_LARGE_STAR_2
    DB 113, -8
    DB -0.1f, 0.7f
    ; Large Star 3
    DB ACTOR_LARGE_STAR_3
    DB 8, 115
    DB 0.35f, -0.7f
    ; Large Star 4
    DB ACTOR_LARGE_STAR_4
    DB 129, 120
    DB -0.15f, -0.6f
    ; Small Star 1
    DB ACTOR_SMALL_STAR_1
    DB 8, 30
    DB 0.3f, 0.3f
    ; Small Star 2
    DB ACTOR_SMALL_STAR_2
    DB 56, 12
    DB 0.2f, 0.4f
    ; Small Star 3
    DB ACTOR_SMALL_STAR_3
    DB 96, 8
    DB -0.1f, 0.4f
    ; Small Star 4
    DB ACTOR_SMALL_STAR_4
    DB 148, 32
    DB -0.2f, 0.3f
    ; Small Star 5
    DB ACTOR_SMALL_STAR_5
    DB 5, 92
    DB 0.3f, -0.2f
    ; Small Star 6
    DB ACTOR_SMALL_STAR_6
    DB 48, 128
    DB 0.2f, -0.3f
    ; Small Star 7
    DB ACTOR_SMALL_STAR_7
    DB 112, 123
    DB -0.1f, -0.3f
.end

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

ScreenTitle::
    ; Start the music
    ld      c, BANK(Inst_Title)
    ld      de, Inst_Title
    call    Music_PrepareInst
    ld      c, BANK(Music_Title)
    ld      de, Music_Title
    call    Music_Play
    
    ld      hl, TitleScrollPosTable
.scrollLoop
    rst     WaitVBlank
    ; Move to the next scroll position
    ld      a, [hli]
    ldh     [hSCY], a
    ASSERT TITLE_SCROLL_END_POS == 0
    and     a, a
    jr      z, .loop
    push    hl
    call    SoundUpdate
    pop     hl
    jr      .scrollLoop

.loop
    rst     WaitVBlank
    
    ldh     a, [hTransitionState]
    ASSERT TRANSITION_STATE_OFF == 0
    and     a, a
    call    nz, TransitionUpdate
    
    call    SoundUpdate
    call    ActorsUpdate
    
    ldh     a, [hFlashCountdown]
    and     a, a
    jr      z, .checkSync
    ; Update flash
    dec     a
    ldh     [hFlashCountdown], a
    jr      nz, .checkSync
    ; Flash is over -> reset to normal palette
    ld      a, TITLE_BGP
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
    ld      a, LOW(TITLE_BGP << 2)  ; One shade lighter than normal
    ldh     [hBGP], a
    ; Reset countdown to flash duration
    ld      a, TITLE_FLASH_DURATION
    ldh     [hFlashCountdown], a
    jr      .noSyncData
.beat
    ; TODO: Fancy bouncing
.noSyncData
    ; Transitioning -> don't take player input
    ldh     a, [hTransitionState]
    ASSERT TRANSITION_STATE_OFF == 0
    and     a, a
    jr      nz, .loop
    
    ldh     a, [hNewKeys]
    and     a, PADF_A | PADF_START
    jr      z, .loop
    
    ; Move to game select screen
    ld      a, SCREEN_GAME_SELECT
    call    TransitionStart
    jr      .loop

SECTION "Title Screen Actor", ROMX

xActorTitle::
    ; Check if it's time to bounce
    ld      a, [wMusicSyncData]
    ASSERT SYNC_TITLE_BEAT == 1
    dec     a
    ret     nz
    
    ; Bounce to the beat
    ; Stars move inward -> bounce is just resetting the position
    ASSERT HIGH(MAX_ACTOR_COUNT * 5 + 1) == 0
    ld      a, c
    add     a, a    ; actor index * 2
    add     a, a    ; actor index * 4
    add     a, c    ; actor index * 5
    inc     a       ; Skip actor type to get to actor position
    add     a, LOW(ActorStarDefinitions)
    ld      l, a
    ASSERT WARN, HIGH(ActorStarDefinitions.end - 1) != HIGH(ActorStarDefinitions)
    adc     a, HIGH(ActorStarDefinitions)
    sub     a, l
    ld      h, a
    
    ld      a, [hli]    ; a = X position
    ld      e, [hl]     ; e = Y position
    
    ; Reset position
    ld      hl, wActorXPosTable
    add     hl, bc
    ld      [hl], a
    ld      hl, wActorYPosTable
    add     hl, bc
    ld      [hl], e
    ret
