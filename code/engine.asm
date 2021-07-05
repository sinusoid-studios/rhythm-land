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

SECTION "Engine", ROM0

; Prepare the engine for a game
; NOTE: Call Music_Play before this!!!
; @param    c   Bank number of cue table
; @param    de  Pointer to cue table
EngineInit::
    push    bc
    push    de
    ; Sync to the music
    ; Call 1: PLAYINST command
    call    SoundSystem_Process
    ; Call 2: Instrument actually updated
    call    SoundSystem_Process
    pop     de
    pop     bc
    
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
    ; Update cues
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
    ; Set countdown to next cue delay
    ld      a, [hli]
    ASSERT CUES_END == -1
    inc     a       ; a = -1
    jr      z, .cuesEnd
    
    dec     a       ; Undo inc
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
