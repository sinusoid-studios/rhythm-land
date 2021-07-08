INCLUDE "defines.inc"

SECTION "Engine Variables", HRAM

; Bank number of current game's cue table
hCueTableBank:
    DS 1
; Pointer to current position in current game's cue table
hCueTablePointer:
.low
    DS 1
.high
    DS 1
; Number of frames until next cue
hCueCountdown:
    DS 1

; Bank number of current game's hit table
hHitTableBank:
    DS 1
; Pointer to current position in current game's hit table
hHitTablePointer:
.low
    DS 1
.high
    DS 1
; Keys that the player must press for the next hit
hNextHitKeys::
    DS 1
; Keys that the player must press for the last hit
hLastHitKeys::
    DS 1
; Number of frame until next hit
hNextHit::
    DS 1
; Number of frames since last hit
hLastHit::
    DS 1

; Number of OK hits the player made (somewhat on-time)
hHitOkCount::
    DS 1
; Number of Perfect hits the player made (right on-time)
hHitPerfectCount::
    DS 1

SECTION "Engine Initialization", ROM0

; Prepare the engine for a game
; NOTE: Call Music_Play before this!!!
; @param    c   Bank number of cue table
; @param    b   Bank number of hit table
; @param    de  Pointer to cue table
; @param    hl  Pointer to hit table
EngineInit::
    ; Save current bank to restore when finished
    ldh     a, [hCurrentBank]
    push    af
    
    ; Set hit table pointer
    ld      a, b
    ldh     [hHitTableBank], a
    ldh     [hCurrentBank], a
    ld      [rROMB0], a
    ld      a, l
    ldh     [hHitTablePointer.low], a
    ld      a, h
    ldh     [hHitTablePointer.high], a
    call    SetNextHit.skip
    
    ; Set cue table pointer
    ld      hl, hCueTableBank
    ld      a, c
    ld      [hli], a
    ASSERT hCueTablePointer == hCueTableBank + 1
    ld      [hl], e
    inc     l
    ld      [hl], d
    
    ; Reset hit rating counts
    ld      l, LOW(hHitOkCount)
    xor     a, a
    ld      [hli], a
    ASSERT hHitPerfectCount == hHitOkCount + 1
    ld      [hli], a
    
    ; Set first cue
    ld      a, c
    ldh     [hCurrentBank], a
    ld      [rROMB0], a
    ld      l, e
    ld      h, d
    jp      SetNextCue

SECTION "Engine Update", ROM0

; Advance a frame in the cue table
EngineUpdate::
    ldh     a, [hNewKeys]
    and     a, a
    jr      z, .noHit
    
    ; Player pressed keys: Give rating based on how on-time it was
    ld      b, a    ; Save for checking correctness
    ld      hl, hLastHit
    ld      e, LOW(hLastHitKeys)
    ld      d, h
    ld      a, [hl]
    ; Check if the next hit is closer (player is early)
    ASSERT hNextHit == hLastHit - 1
    dec     l
    cp      a, [hl]
    jr      c, .notEarly
    ld      a, [hl]
.notEarly
    ; Check if the player pressed the hit keys
    ld      c, a    ; Save
    ld      a, [de]
    and     a, b    ; b = [hNewKeys]
    ; The player hit other keys; ignore
    jr      z, .noHit
    
    ld      a, c    ; Restore
    ; Miss
    cp      a, HIT_OK_WINDOW / 2
    jr      nc, .noHit
    
    ; OK
    ld      l, LOW(hHitOkCount)
    cp      a, HIT_PERFECT_WINDOW / 2
    jr      nc, .gotRating
    
    ; Perfect
    ASSERT hHitPerfectCount == hHitOkCount + 1
    inc     l

.gotRating
    ; Increment number of this rating of hit for each pressed key
    inc     [hl]
.next
    srl     b       ; b = [hNewKeys]
    jr      z, .noHit
    jr      nc, .next
    jr      .gotRating

.noHit
    ; Update hit timing
    
    ; Save current bank to restore when finished
    ldh     a, [hCurrentBank]
    push    af
    
    ; Last hit moves farther away
    ld      hl, hLastHit
    inc     [hl]
    
    ldh     a, [hHitTableBank]
    and     a, a    ; Bank number 0 = no more hits (finished)
    jr      z, .updateCues
    
    ASSERT hNextHit == hLastHit - 1
    dec     l
    ; Next hit comes closer
    dec     [hl]    ; hl = hNextHit
    call    z, SetNextHit

.updateCues
    ldh     a, [hCueTableBank]
    and     a, a    ; Bank number 0 = no cue updates (finished)
    jr      z, BankedReturn
    
    ld      hl, hCueCountdown
    dec     [hl]
    jr      nz, BankedReturn    ; Still waiting; nothing to do
    
    ; Countdown hit 0, call the cue subroutine
    ld      b, a        ; a = [hCueTableBank]
    
    ; Get the current position in the cue table
    ld      a, b
    ldh     [hCurrentBank], a
    ld      [rROMB0], a
    ld      hl, hCueTablePointer
    ld      a, [hli]
    ld      h, [hl]
    ld      l, a
    ; Fall-through

; Call the next cue's subroutine
; @param    hl  Pointer to current position in cue table (hCueTablePointer)
FireCue:
    ; Get a pointer to the cue's subroutine
    ld      a, [hl]     ; a = Cue ID
    add     a, a        ; a * 2 (Pointer)
    add     a, [hl]     ; a * 3 (+Bank)
    add     a, LOW(CueRoutineTable)
    ld      l, a
    ASSERT HIGH(CueRoutineTable.end - 1) == HIGH(CueRoutineTable)
    ld      h, HIGH(CueRoutineTable)
    
    ; Call the subroutine
    ld      a, [hli]
    ldh     [hCurrentBank], a
    ld      [rROMB0], a
    ld      a, [hli]
    ld      h, [hl]
    ld      l, a
    rst     JP_HL
    
    ; Move to next cue
    ldh     a, [hCueTableBank]
    ldh     [hCurrentBank], a
    ld      [rROMB0], a
    ld      hl, hCueTablePointer
    ld      a, [hli]
    ld      h, [hl]
    ld      l, a
    inc     hl
    ; Fall-through

; Update the cue countdown for the next cue in the table
; @param    hl  Pointer to current position in cue table (hCueTablePointer)
SetNextCue:
    ; Get next cue delay
    ld      a, [hli]
    ASSERT CUES_END == -1
    inc     a       ; a = -1
    jr      z, .cuesEnd
    
    dec     a       ; Undo inc
    jr      z, .zeroCue
    ; Set countdown
    ld      [hCueCountdown], a
    ; Save new pointer
    ld      a, l
    ldh     [hCueTablePointer.low], a
    ld      a, h
    ldh     [hCueTablePointer.high], a
    jr      BankedReturn

.zeroCue
    ; Fire this cue immediately
    ; Save new pointer
    ld      a, l
    ldh     [hCueTablePointer.low], a
    ld      a, h
    ldh     [hCueTablePointer.high], a
    
    ; Fire this cue
    ldh     a, [hCueTableBank]
    ldh     [hCurrentBank], a
    ld      [rROMB0], a
    jr      FireCue

.cuesEnd
    ; No more cues
    ; Set cue table bank to 0 to signal no cue updates
    ; a = 0
    ldh     [hCueTableBank], a
    ; Fall-through

BankedReturn:
    ; Restore caller's bank
    pop     af
    ldh     [hCurrentBank], a
    ld      [rROMB0], a
    ret

SECTION "Engine Next Hit Preparation", ROM0

SetNextHit:
    ; Get the current position in the hit table
    ldh     a, [hHitTableBank]
    ldh     [hCurrentBank], a
    ld      [rROMB0], a
    ld      hl, hHitTablePointer
    ld      a, [hli]
    ld      h, [hl]
    ld      l, a
.skip
    ; Get next hit delay
    ld      a, [hli]
    ASSERT HITS_END == -1
    inc     a       ; a = -1
    jr      z, .hitsEnd
    
    dec     a       ; Undo inc
    ; Set hit timing
    ldh     [hNextHit], a
    xor     a, a
    ldh     [hLastHit], a
    ; Set hit keys
    ldh     a, [hNextHitKeys]
    ldh     [hLastHitKeys], a
    ld      a, [hli]
    ldh     [hNextHitKeys], a
    
    ; Save new pointer
    ld      a, l
    ldh     [hHitTablePointer.low], a
    ld      a, h
    ldh     [hHitTablePointer.high], a
    ret

.hitsEnd
    ; No more hits
    ; Set hit table bank to 0 to signal no hit updates
    ; a = 0
    ldh     [hHitTableBank], a
    ret
