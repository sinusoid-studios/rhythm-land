INCLUDE "constants/hardware.inc"
INCLUDE "constants/actors.inc"
INCLUDE "constants/engine.inc"
INCLUDE "constants/transition.inc"
INCLUDE "constants/screens.inc"
INCLUDE "constants/SoundSystem.inc"
INCLUDE "constants/SoundSystemNotes.inc"
INCLUDE "constants/sfx.inc"
INCLUDE "constants/games/seagull-serenade.inc"

SECTION UNION "Game Variables", HRAM

hEndDelay:
    DS 1

; Current position in xSquawkNoteTable, incremented every non-player
; squawk
hSquawkIndex:
    DS 1

SECTION "Seagull Serenade Game Setup", ROMX

xGameSetupSeagullSerenade::
    ; Set palettes
    ld      a, SEAGULL_SERENADE_BGP
    ldh     [hBGP], a
    ld      a, SEAGULL_SERENADE_OBP0
    ldh     [hOBP0], a
    
    ; Set appropriate LCDC flags
    ld      a, LCDCF_ON | LCDCF_BG8800 | LCDCF_BG9800 | LCDCF_BGON | LCDCF_OBJ16 | LCDCF_OBJON
    ldh     [hLCDC], a
    
    ; Load background tiles
    ASSERT BANK(xBackgroundTiles9000) == BANK(@)
    ld      de, xBackgroundTiles9000
    ld      hl, $9000
    ld      bc, xBackgroundTiles9000.end - xBackgroundTiles9000
    rst     LCDMemcopy
    ASSERT BANK(xBackgroundTiles8800) == BANK(@)
    ASSERT xBackgroundTiles8800 == xBackgroundTiles9000.end
    ; de = xBackgroundTiles8800
    ld      hl, $8800
    ld      bc, xBackgroundTiles8800.end - xBackgroundTiles8800
    rst     LCDMemcopy
    
    ; Load background map
    ASSERT BANK(xMap) == BANK(@)
    ASSERT xMap == xBackgroundTiles8800.end
    ; de = xMap
    ld      hl, _SCRN0
    ld      c, SCRN_Y_B
    call    LCDMemcopyMap
    
    ; Enable tile streaming
    ; a = 1
    ldh     [hTileStreamingEnable], a
    
    ; Create seagull actors
    ld      de, xActorSeagullDefinitions
    ASSERT SEAGULL_COUNT == 3
    call    ActorNew
    call    ActorNew
    call    ActorNew
    
    ; Delay after the music ends
    ld      a, END_DELAY
    ldh     [hEndDelay], a
    
    ; Index is incremented before use, so start with -1 for the first
    ; squawk
    ld      a, -1
    ldh     [hSquawkIndex], a
    
    ; Set up game data
    ld      c, BANK(xHitTableSeagullSerenade)
    ld      hl, xHitTableSeagullSerenade
    jp      EngineInit

xActorSeagullDefinitions:
    ; Seagull 1
    DB ACTOR_SEAGULL_1
    DB SEAGULL_1_X, SEAGULL_1_Y
    DB 0, 0
    ; Seagull 2
    DB ACTOR_SEAGULL_2
    DB SEAGULL_2_X, SEAGULL_2_Y
    DB 0, 0
    ; Seagull 3
    DB ACTOR_SEAGULL_3
    DB SEAGULL_3_X, SEAGULL_3_Y
    DB 0, 0

xBackgroundTiles9000:
    INCBIN "res/seagull-serenade/background.bg.2bpp", 0, 128 * 16
.end
xBackgroundTiles8800:
    INCBIN "res/seagull-serenade/background.bg.2bpp", 128 * 16
.end

xMap:
    INCBIN "res/seagull-serenade/background.bg.tilemap"

SECTION "Seagull Serenade Game Loop", ROMX

xGameSeagullSerenade::
    rst     WaitVBlank
    
    ldh     a, [hTransitionState]
    ASSERT TRANSITION_STATE_OFF == 0
    and     a, a
    jr      z, .noTransition
    
    call    TransitionUpdate
    
    ldh     a, [hTransitionState]
    ASSERT TRANSITION_STATE_OFF == 0
    and     a, a
    jr      nz, xGameSeagullSerenade
    
    ; Start music
    ld      c, BANK(Inst_SeagullSerenade)
    ld      de, Inst_SeagullSerenade
    call    Music_PrepareInst
    ld      c, BANK(Music_SeagullSerenade)
    ld      de, Music_SeagullSerenade
    call    Music_Play
    jr      xGameSeagullSerenade

.noTransition
    ; Left and Right perform the same action -> combine them into the
    ; Left bit
    ldh     a, [hNewKeys]
    bit     PADB_RIGHT, a
    jr      z, .noRight
    res     PADB_RIGHT, a
    set     PADB_LEFT, a
    ldh     [hNewKeys], a
.noRight
    
    call    EngineUpdate
    call    ActorsUpdate
    
    ; Play squawk sound effects
    ld      a, [wMusicSyncData]
    ; Squawk sync values will only use the low 3 bits
    and     a, ~%111
    jr      z, .squawk
    
.squawkDone
    ld      a, [wMusicPlayState]
    ASSERT MUSIC_STATE_STOPPED == 0
    and     a, a
    jr      nz, xGameSeagullSerenade
    ldh     a, [hEndDelay]
    dec     a
    ldh     [hEndDelay], a
    jr      nz, xGameSeagullSerenade
    
    ; Game is over -> go to the overall rating screen
    ld      a, SCREEN_RATING
    call    TransitionStart
    jr      xGameSeagullSerenade

.squawk
    ldh     a, [hSquawkIndex]
    inc     a
    ldh     [hSquawkIndex], a
    add     a, LOW(xSquawkNoteTable)
    ld      l, a
    ASSERT HIGH(xSquawkNoteTable.end - 1) == HIGH(xSquawkNoteTable)
    ld      h, HIGH(xSquawkNoteTable)
    
    ld      b, SFX_SEAGULL_SQUAWK
    ld      c, [hl] ; c = note
    call    SFX_Play
    jr      .squawkDone

xSquawkNoteTable:
    ; Seagull 1, Seagull 2
    REPT 2
    DB C_6, E_6
    DB F_6, A_6
    DB C_6, E_6
    DB G_6, G_6
    DB F_6, F_6
    ENDR
    
    DB E_7, C_7
    DB A_6, A_6
    DB E_6, G_6
    DB C_7, A_6
    DB F_6, F_6
    DB C_6, E_6
    
    DB C_6, E_6
    DB F_6, A_6
    DB C_6, E_6
    DB G_6, G_6
    DB F_6, F_6
    
    DB C_6, E_6
    DB C_7, A_6
    DB C_6, E_6
    DB G_6, E_6
    DB G_6, G_6
    DB F_6, F_6
.end

SECTION "Seagull Serenade Seagull Actors", ROMX

xActorSeagull::
    ; Check for sync actions
    ld      a, [wMusicSyncData]
    ASSERT SYNC_NONE == -1
    inc     a
    jr      z, xActorSeagullNoSquawk
    
    ; Add 1 to compensate for inc
    cp      a, SYNC_SEAGULL_SERENADE_GROOVE + 1
    jr      z, .groove
    
    ; Squawk
    dec     a       ; Undo inc
    ; Check if this is meant for this seagull
    ld      d, a    ; Save for checking type of squawk
    and     a, 1    ; a = 0 or 1
    cp      a, c    ; c = actor index (0 or 1)
    jr      nz, xActorSeagullNoSquawk
    
    ; Squawk the right squawk
    ld      a, d    ; d = sync data
    srl     a       ; a = 0-2
    ; 0 = low
    ; 1 = mid
    ; 2 = high
    jr      z, .low
    dec     a
    jr      z, .mid
    ; High
    ld      a, CEL_SEAGULL_HIGH
    jp      ActorSetAnimationOverride
.low
    ld      a, CEL_SEAGULL_LOW
    jp      ActorSetAnimationOverride
.mid
    ld      a, CEL_SEAGULL_MID
    jp      ActorSetAnimationOverride

.groove
    ; Stop bobbing and start to really get in the groove
    ld      a, CEL_SEAGULL_GROOVE
    jp      ActorSetCel

xActorSeagullPlayer::
    ; Check for sync actions
    ld      a, [wMusicSyncData]
    cp      a, SYNC_SEAGULL_SERENADE_GROOVE
    jr      nz, .noSync
    
    ; Stop bobbing and start to really get in the groove
    ld      a, CEL_SEAGULL_GROOVE
    jp      ActorSetCel

.noSync
    ; Check if the player pressed a hit key
    ldh     a, [hNewKeys]
    ; Save squawk type
    ld      hl, hScratch3
    ld      [hl], 0
    
    ; Down -> low squawk
    bit     PADB_DOWN, a
    jr      nz, .low
    ; Left/Right -> mid squawk
    inc     [hl]
    bit     PADB_LEFT, a
    jr      nz, .mid
    ; Up -> high squawk
    inc     [hl]
    bit     PADB_UP, a
    jr      z, xActorSeagullNoSquawk
    
    ld      a, CEL_SEAGULL_HIGH
    call    ActorSetAnimationOverride
    jr      .playSFX
.low
    ld      a, CEL_SEAGULL_LOW
    call    ActorSetAnimationOverride
    jr      .playSFX
.mid
    ld      a, CEL_SEAGULL_MID
    call    ActorSetAnimationOverride
.playSFX
    ldh     a, [hLastPlayerHitNumber]
    ld      d, a
    add     a, a    ; hit number * 2
    add     a, d    ; hit number * 3
    ld      d, a
    ldh     a, [hScratch3]
    add     a, d    ; hit number * 3 + squawk type
    add     a, LOW(xPlayerSquawkNoteTable)
    ld      l, a
    ASSERT HIGH(xPlayerSquawkNoteTable.end - 1) == HIGH(xPlayerSquawkNoteTable)
    ld      h, HIGH(xPlayerSquawkNoteTable)
    
    ld      b, SFX_SEAGULL_SQUAWK
    ld      e, c    ; e not destroyed by SFX_Play
    ld      c, [hl] ; c = note
    call    SFX_Play
    ld      c, e
    ASSERT HIGH(MAX_ACTOR_COUNT) == HIGH(0)
    ld      b, 0
    ret

xActorSeagullNoSquawk:
    ; If the player missed this hit (is late enough), switch to the
    ; missed note reaction
    ldh     a, [hLastHit.low]
    cp      a, HIT_MISS_DELAY
    ret     nz
    ldh     a, [hLastHit.high]
    ASSERT HIGH(HIT_MISS_DELAY) == 0
    and     a, a
    ret     nz
    
    ; It's late enough, but did the player already get an OK or Perfect
    ; squawk?
    ldh     a, [hNextHitNumber]
    ld      e, a
    ldh     a, [hLastRatedHitNumber]
    inc     a       ; Comparing with next hit number
    cp      a, e
    ; The player already made this hit -> they're not late
    ret     nc
    
    ; Switch to the missed note reaction
    ld      a, CEL_SEAGULL_MISSED_NOTE
    jp      ActorSetAnimationOverride

xPlayerSquawkNoteTable:
    ; Low, Mid, High
    REPT 2
    DB B_5, D#6, G_6
    DB F#6, G#6, C_7
    DB C#6, F_6, G_6
    DB A#5, D#6, G_6
    DB B_5, F_6, G#6
    ENDR
    
    DB A_6, C#7, D#7
    DB A_6, B_6, F_7
    DB D#6, G#6, B_6
    DB F_6, A#6, B_6
    DB F_6, G#6, C#7
    DB C#6, F_6, C_7
    
    DB B_5, D#6, G_6
    DB F#6, G#6, C_7
    DB C#6, F_6, G_6
    DB A#5, D#6, G_6
    DB B_5, F_6, G#6
    
    DB B_5, D#6, G_6
    DB F_6, A#6, C#7
    DB B_5, D#6, G_6
    DB C_6, F_6, G#6
    DB A#5, D#6, G_6
    DB B_5, F_6, G#6
.end
