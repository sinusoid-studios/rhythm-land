INCLUDE "constants/hardware.inc"
INCLUDE "constants/other-hardware.inc"
INCLUDE "constants/actors.inc"
INCLUDE "constants/transition.inc"
INCLUDE "macros/misc.inc"

SECTION "Screen Transition Variables", HRAM

; Current state of the screen transition
; See constants/transition.inc for possible values
hTransitionState::
    DS 1

; Current position in TransitionPosTable
hTransitionIndex::
    DS 1

; Number of frames until the master volume is decreased a step
hMusicFadeCountdown::
    DS 1

; Screen ID of the screen to transition to
hTransitionNextScreen::
    DS 1

SECTION "Screen Transition Initialization", ROM0

; Start a screen transition
; The next screen will be set up when the screen is fully covered
; @param    a   Screen ID of the next screen
TransitionStart::
    ; Save next screen's ID
    ldh     [hTransitionNextScreen], a
    
    ; Signal transitioning out
    ld      a, TRANSITION_STATE_OUT
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
    
    ; Set initial music fade delay
    ld      a, TRANSITION_MUSIC_FADE_SPEED
    ldh     [hMusicFadeCountdown], a
    
    ; Fill the window black
    ; TODO: Find something better
    
    ; Black tile
    ld      hl, $8FF0
    lb      bc, $FF, 16
    call    LCDMemsetSmall
    ; Fill window tilemap
    ld      hl, _SCRN1
    ; b = $FF
    ld      c, SCRN_Y_B
    call    LCDMemsetMap
    
    ; Enable the window
    ldh     a, [hLCDC]
    ASSERT LCDCF_WINON != 0 && LCDCF_WIN9C00 != 0
    or      a, LCDCF_WINON | LCDCF_WIN9C00
    ldh     [rLCDC], a
    
    ret

SECTION "Screen Transition Update", ROM0

TransitionUpdate::
    ; Advance the transition
    ; Get transition direction
    ldh     a, [hTransitionState]
    ASSERT TRANSITION_STATE_OUT == 1
    dec     a
    ldh     a, [hTransitionIndex]
    jr      nz, .transitionIn
    
    ; Transitioning out
    inc     a
    ; Check if this part of the transition is over
    cp      a, TransitionPosTable.end - TransitionPosTable
    jr      nc, .covered
    
    ldh     [hTransitionIndex], a
    ; Set first block's position before LY 0
    ASSERT LOW(TransitionPosTable) == 0
    ld      l, a
    ASSERT HIGH(TransitionPosTable.end - 1) == HIGH(TransitionPosTable)
    ld      h, HIGH(TransitionPosTable)
    ld      a, [hl]
    ldh     [rWX], a
    
    ; This must also be called when transitioning in if it cuts into
    ; that time
    ASSERT TRANSITION_MUSIC_FADE_SPEED * 8 <= TRANSITION_DURATION + TRANSITION_DELAY
    jp      MusicFadeOut

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
    
    ; Discard return address (switching screens)
    pop     af
    
    ; Remove all sprites
    ; Set all actors to empty
    ld      a, ACTOR_EMPTY
    ld      hl, wActorTypeTable
    ld      c, MAX_ACTOR_COUNT
    rst     MemsetSmall
    ; Hide all existing objects
    call    HideAllObjects
    
    ; Get next screen's ID
    ldh     a, [hTransitionNextScreen]
    ld      b, a
    add     a, a    ; a * 2 (Pointer)
    add     a, b    ; a * 3 (+Bank)
    add     a, LOW(ScreenSetupTable)
    ld      l, a
    ASSERT HIGH(ScreenSetupTable.end - 1) == HIGH(ScreenSetupTable)
    ld      h, HIGH(ScreenSetupTable)
    
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
    
    ; Start transitioning in
    ld      a, TRANSITION_STATE_IN
    ldh     [hTransitionState], a
    
    ; Animate this part in reverse
    ld      a, TransitionPosTable.end - TransitionPosTable - 1
    ldh     [hTransitionIndex], a
    
    ; Jump into the next screen's loop
    ldh     a, [hTransitionNextScreen]
    ; Switch to the next screen
    ldh     [hCurrentScreen], a
    ld      b, a
    add     a, a    ; a * 2 (Pointer)
    add     a, b    ; a * 3 (+Bank)
    add     a, LOW(ScreenTable)
    ld      l, a
    ASSERT HIGH(ScreenTable.end - 1) == HIGH(ScreenTable)
    ld      h, HIGH(ScreenTable)
    
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

.transitionIn
    ; Transitioning into the next screen
    dec     a
    ; Check if this part of the transition is over
    jr      z, .finished
    
    ldh     [hTransitionIndex], a
    ; Set first block's position before LY 0
    ASSERT LOW(TransitionPosTable) == 0
    ld      l, a
    ASSERT HIGH(TransitionPosTable.end - 1) == HIGH(TransitionPosTable)
    ld      h, HIGH(TransitionPosTable)
    ld      a, [hl]
    ldh     [rWX], a
    ret

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
    ret

SECTION "Music Fade Out", ROM0

; This can be inlined if it doesn't cut into the delay (separate loop)
ASSERT TRANSITION_MUSIC_FADE_SPEED * 8 > TRANSITION_DURATION

MusicFadeOut:
    ldh     a, [hMusicFadeCountdown]
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
    ldh     [hMusicFadeCountdown], a
    ret
