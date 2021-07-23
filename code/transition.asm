INCLUDE "constants/hardware.inc"
INCLUDE "constants/other-hardware.inc"
INCLUDE "constants/actors.inc"
INCLUDE "constants/transition.inc"

SECTION "Screen Transition Variables", HRAM

; Current state of the screen transition
; See constants/transition.inc for possible values
hTransitionState::
    DS 1

; Current position in TransitionPosTable
hTransitionIndex::
    DS 1

SECTION "Screen Transition", ROM0

; Start a screen transition and wait for it to complete
; The next screen will be set up when the screen is fully covered
; @param    a   Game ID of the next screen
Transition::
    ; Save next screen's game ID
    ldh     [hCurrentGame], a
    
    ; Signal transition coming in
    ld      a, TRANSITION_STATE_IN
    ldh     [hTransitionState], a
    
    ; Reset transition position index
    xor     a, a
    ldh     [hTransitionIndex], a
    
    ; Window always filling the screen vertically
    ; a = 0
    ldh     [rWY], a
    ; Hide the window initially
    ld      a, SCRN_X + 7
    ldh     [rWX], a
    
    ; Set initial music fade delay (use hScratch2 for it)
    ld      a, TRANSITION_MUSIC_FADE_SPEED
    ldh     [hScratch2], a
    
.animate
    ; Enable the window
    ldh     a, [hLCDC]
    ASSERT LCDCF_WINON != 0 && LCDCF_WIN9C00 != 0
    or      a, LCDCF_WINON | LCDCF_WIN9C00
    ldh     [rLCDC], a
    
.loop
    rst     WaitVBlank
    
    ; Advance the transition
    ; Get transition direction
    ldh     a, [hTransitionState]
    ASSERT TRANSITION_STATE_IN == 1
    dec     a
    ldh     a, [hTransitionIndex]
    jr      nz, .goingOut
    
    ; Transition is coming in
    inc     a
    ; Check if this part of the transition is over
    cp      a, TransitionPosTable.end - TransitionPosTable
    jr      nc, .covered
    
    ldh     [hTransitionIndex], a
    ; Set first block's position before LY 0
    add     a, LOW(TransitionPosTable)
    ld      l, a
    ASSERT HIGH(TransitionPosTable.end - 1) == HIGH(TransitionPosTable)
    ld      h, HIGH(TransitionPosTable)
    ld      a, [hl]
    ldh     [rWX], a
    
    ; This must also be called when the transition is going out if it
    ; cuts into that time
    ASSERT TRANSITION_MUSIC_FADE_SPEED * 8 <= TRANSITION_DURATION + TRANSITION_DELAY
    call    MusicFadeOut
    jr      .loop

.covered
    ; The screen is now entirely covered, so setup for the next screen
    ; can be done!
    
    ; Stop updating the window mid-frame and ensure the LYC interrupt is
    ; for the sound update
    xor     a, a
    ldh     [rLYC], a
    
    ; Update transition state
    ld      a, TRANSITION_STATE_MID
    ldh     [hTransitionState], a
    
    ; Remove all sprites
    ; Set all actors to empty
    ld      a, ACTOR_EMPTY
    ld      hl, wActorTypeTable
    ld      c, MAX_NUM_ACTORS
    rst     MemsetSmall
    ; Hide all existing objects
    call    HideAllObjects
    
    ; Get next screen's game ID
    ldh     a, [hCurrentGame]
    ld      b, a
    add     a, a    ; a * 2 (Pointer)
    add     a, b    ; a * 3 (+Bank)
    add     a, LOW(GameSetupTable)
    ld      l, a
    ASSERT HIGH(GameSetupTable.end - 1) == HIGH(GameSetupTable)
    ld      h, HIGH(GameSetupTable)
    
    ld      a, [hli]
    ; Switching the bank to 0 in this case is benign but still triggers
    ; an exception in bgb
    and     a, a
    jr      z, .skipBank1
    ldh     [hCurrentBank], a
    ld      [rROMB0], a
.skipBank1
    ld      a, [hli]
    ld      h, [hl]
    ld      l, a
    rst     JP_HL
    
    ; Delay a little bit
    ld      a, TRANSITION_DELAY
    ldh     [hScratch1], a
.delayLoop
    rst     WaitVBlank
    call    MusicFadeOut
    ldh     a, [hScratch1]
    dec     a
    ldh     [hScratch1], a
    jr      nz, .delayLoop
    
    ; Start moving the transition out
    ld      a, TRANSITION_STATE_OUT
    ldh     [hTransitionState], a
    
    ; Animate this part in reverse
    ld      a, TransitionPosTable.end - TransitionPosTable - 1
    ldh     [hTransitionIndex], a
    jr      .animate

.goingOut
    ; Transition is going out
    dec     a
    ; Check if this part of the transition is over
    jr      z, .finished
    
    ldh     [hTransitionIndex], a
    ; Set first block's position before LY 0
    add     a, LOW(TransitionPosTable)
    ld      l, a
    ASSERT HIGH(TransitionPosTable.end - 1) == HIGH(TransitionPosTable)
    ld      h, HIGH(TransitionPosTable)
    ld      a, [hl]
    ldh     [rWX], a
    jr      .loop

.finished
    ; Stop updating the window mid-frame and ensure the LYC interrupt is
    ; for the sound update
    ; a = 0
    ldh     [rLYC], a
    
    ; Hide the window
    ld      a, SCRN_X + 7
    ldh     [rWX], a
    
    ; Turn the transition off
    ASSERT TRANSITION_STATE_OFF == 0
    xor     a, a
    ldh     [hTransitionState], a
    
    ; Jump into the next screen's loop
    ldh     a, [hCurrentGame]
    ld      b, a
    add     a, a    ; a * 2 (Pointer)
    add     a, b    ; a * 3 (+Bank)
    add     a, LOW(GameTable)
    ld      l, a
    ; ASSERT HIGH(GameTable.end - 1) != HIGH(GameTable)
    adc     a, HIGH(GameTable)
    sub     a, l
    ld      h, a
    
    ld      a, [hli]
    ; Switching the bank to 0 in this case is benign but still triggers
    ; an exception in bgb
    and     a, a
    jr      z, .skipBank2
    ldh     [hCurrentBank], a
    ld      [rROMB0], a
.skipBank2
    ld      a, [hli]
    ld      h, [hl]
    ld      l, a
    jp      hl

SECTION "Music Fade Out", ROM0

; This can be inlined if it doesn't cut into the delay (separate loop)
ASSERT TRANSITION_MUSIC_FADE_SPEED * 8 > TRANSITION_DURATION

MusicFadeOut:
    ldh     a, [hScratch2]
    dec     a
    jr      nz, .noDecrease
    ; Subtract 1 from volume on each terminal
    ldh     a, [rNR50]
    sub     a, $11
    jr      c, .musicOff
    ldh     [rNR50], a
    ; Reset countdown
    ld      a, TRANSITION_MUSIC_FADE_SPEED
    jr      .noDecrease
.musicOff
    ; Stop the music (master volume = 0 isn't silent)
    call    Music_Pause
    ; Reset master volume to max, excluding VIN signal
    ld      a, $FF ^ (AUDVOL_VIN_LEFT | AUDVOL_VIN_RIGHT)
    ldh     [rNR50], a
    ; Countdown will become -1 next frame
    ASSERT LOW(-1) > TRANSITION_DURATION - TRANSITION_MUSIC_FADE_SPEED * 8
    xor     a, a
.noDecrease
    ldh     [hScratch2], a
    ret
