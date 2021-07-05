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
hNextHitKeys:
    DS 1
; Keys that the player must press for the last hit
hLastHitKeys:
    DS 1
; Number of frame until next hit
hNextHit::
    DS 1
; Number of frames since last hit
hLastHit::
    DS 1

SECTION "Engine", ROM0

; Prepare the engine for a game
; NOTE: Call Music_Play before this!!!
; @param    c   Bank number of cue table
; @param    b   Bank number of hit table
; @param    de  Pointer to cue table
; @param    hl  Pointer to hit table
EngineInit::
    push    bc
    push    de
    push    hl
    ; Sync to the music
    ; Call 1: PLAYINST command
    call    SoundSystem_Process
    ; Call 2: Instrument actually updated
    call    SoundSystem_Process
    pop     hl
    pop     de
    pop     bc
    
    ; Set hit table pointer
    ld      a, b
    ldh     [hHitTableBank], a
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
    
    ; Set first cue
    ld      [rROMB0], a     ; a = [hCueTableBank]
    ld      l, e
    ld      h, d
    jr      SetNextCue

; Advance a frame in the cue table
EngineUpdate::
    ; Update hit timing
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
    ret     z
    
    ld      hl, hCueCountdown
    dec     [hl]
    ret     nz      ; Still waiting; nothing to do
    
    ; Countdown hit 0, call the cue subroutine
    ; Get the current position in the cue table
    ld      [rROMB0], a     ; a = [hCueTableBank]
    ld      hl, hCueTablePointer
    ld      a, [hli]
    ld      h, [hl]
    ld      l, a
    
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
    ld      [rROMB0], a
    ld      a, [hli]
    ld      h, [hl]
    ld      l, a
    rst     JP_HL
    
    ; Move to next cue
    ldh     a, [hCueTableBank]
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
    ; Set countdown
    ld      [hCueCountdown], a
    ; Save new pointer
    ld      a, l
    ldh     [hCueTablePointer.low], a
    ld      a, h
    ldh     [hCueTablePointer.high], a
    ret

.cuesEnd
    ; No more cues
    ; Set cue table bank to 0 to signal no cue updates
    ; a = 0
    ldh     [hCueTableBank], a
    ret

SetNextHit:
    ; Get the current position in the hit table
    ldh     a, [hHitTableBank]
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
