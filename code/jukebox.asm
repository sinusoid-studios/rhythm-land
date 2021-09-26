INCLUDE "constants/hardware.inc"
INCLUDE "constants/jukebox.inc"
INCLUDE "constants/transition.inc"
INCLUDE "constants/screens.inc"

SECTION UNION "Game Variables", HRAM

hCurrentSong:
    DS 1

SECTION "Jukebox Setup", ROM0

ScreenSetupJukebox::
    ; Set palette
    ld      a, JUKEBOX_BGP
    ldh     [hBGP], a
    
    ; Set appropriate LCDC flags
    ld      a, LCDCF_ON | LCDCF_BG8800 | LCDCF_BG9800 | LCDCF_BGON | LCDCF_OBJ16 | LCDCF_OBJON
    ldh     [hLCDC], a
    
    ; Load background tiles
    ld      de, BackgroundTiles
    ld      hl, $9000
    ld      bc, BackgroundTiles.end - BackgroundTiles
    rst     LCDMemcopy
    
    ; Reset current song
    xor     a, a
    ldh     [hCurrentSong], a
    
    ; Load background map
    ld      de, Map
    ld      hl, _SCRN0
    ld      c, SCRN_Y_B
    jp      LCDMemcopyMap

SECTION "Jukebox Background Tiles", ROM0

BackgroundTiles:
    INCBIN "res/jukebox/background.bg.2bpp"
.end

SECTION "Jukebox Background Map", ROM0

Map:
    INCBIN "res/jukebox/background.bg.tilemap"

SECTION "Jukebox", ROM0

ScreenJukebox::
    rst     WaitVBlank
    
    ldh     a, [hTransitionState]
    ASSERT TRANSITION_STATE_OFF == 0
    and     a, a
    call    nz, TransitionUpdate
    
    ; Calling SoundSystem_Process directly instead of SoundUpdate
    ; because this is in ROM0 and there is no sync data to be looking
    ; for
    call    SoundSystem_Process
    
    ; Don't take input if transition is still going
    ldh     a, [hTransitionState]
    ASSERT TRANSITION_STATE_OFF == 0
    and     a, a
    jr      nz, ScreenJukebox
    
    ldh     a, [hNewKeys]
    bit     PADB_B, a
    jr      nz, .back
    bit     PADB_UP, a
    jr      nz, .up
.retUp
    ldh     a, [hNewKeys]
    bit     PADB_DOWN, a
    jr      nz, .down
.retDown
    ldh     a, [hNewKeys]
    ASSERT PADB_A == 0
    rra     ; Move bit 0 to carry
    jr      c, .play
    jr      ScreenJukebox

.up
    ldh     a, [hCurrentSong]
    and     a, a
    jr      z, .retUp
    dec     a
    ldh     [hCurrentSong], a
    jr      .retUp
.down
    ldh     a, [hCurrentSong]
    cp      a, (SongDataTable.end - SongDataTable) / 6 - 1
    jr      nc, .retDown
    inc     a
    ldh     [hCurrentSong], a
    jr      .retDown

.play
    ; Get pointer to music data
    ldh     a, [hCurrentSong]
    add     a, a    ; song * 2 (Inst pointer)
    ld      b, a
    add     a, a    ; song * 4 (Music pointer)
    add     a, b    ; song * 6 (Inst bank + Music bank)
    add     a, LOW(SongDataTable)
    ld      l, a
    ASSERT HIGH(SongDataTable.end - 1) == HIGH(SongDataTable)
    ld      h, HIGH(SongDataTable)
    ; Prepare Insts
    ld      a, [hli]
    ld      c, a    ; c = bank number
    ld      a, [hli]
    ld      e, a
    ; Don't use `ld d, [hl]` because the auto-increment is needed for
    ; getting the Music pointer
    ld      a, [hli]
    ld      d, a
    ; de = Inst pointer
    push    hl  ; Save to get the Music pointer
    call    Music_PrepareInst
    
    ; Play Music
    pop     hl
    ld      a, [hli]
    ld      c, a    ; c = bank number
    ld      a, [hli]
    ld      d, [hl]
    ld      e, a
    ; de = Music pointer
    call    Music_Play
    jr      ScreenJukebox

.back
    ld      a, SCREEN_GAME_SELECT
    call    TransitionStart
    jr      ScreenJukebox
