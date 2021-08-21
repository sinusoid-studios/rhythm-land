INCLUDE "constants/hardware.inc"
INCLUDE "constants/other-hardware.inc"
INCLUDE "constants/actors.inc"
INCLUDE "constants/transition.inc"
INCLUDE "constants/interrupts.inc"
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
    ld      a, SCRN_X + WX_OFS
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
    ; Don't write to hLCDC but instead write to rLCDC so if a screen
    ; setup routine overwrites hLCDC, the window is still enabled.
    ; Because of this, hLCDC is not copied to rLCDC during a transition.
    ldh     [rLCDC], a
    
    ; Let the VBlank interrupt handler set up the next LYC value.
    ; All that needs to be done here is actually enable LYC interrupts.
    ; If LYC interrupts are already enabled, there's nothing to do.
    ld      hl, rIE
    bit     IEB_STAT, [hl]
    ret     nz
    
    ; Need to enable LYC interrupts, but also ensure it doesn't trigger
    ; before VBlank
    ASSERT HIGH(rIE) > SCRN_Y
    ld      a, h
    ldh     [rLYC], a
    
    ; Clear any pending LYC interrupt
    ld      l, LOW(rIF)
    res     IEB_STAT, [hl]
    ; Enable LYC interrupts
    ASSERT LOW(rIE) == HIGH(rIF)
    ld      l, h
    set     IEB_STAT, [hl]
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
    
    ; Disable all LYC interrupts
    ld      hl, rIE
    res     IEB_STAT, [hl]
    ASSERT LOW(LYC_INDEX_NONE) == HIGH(rIE)
    ld      a, h
    ldh     [hLYCIndex], a
    ldh     [hLYCResetIndex], a
    
    ; Update transition state
    ld      a, TRANSITION_STATE_MID
    ldh     [hTransitionState], a
    
    ; Discard return address (switching screens)
    pop     af
    
    ; Remove all sprites
    ; Set all actors to empty
    ASSERT LOW(ACTOR_EMPTY) == HIGH(rIE)
    ld      a, h
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
    
    ; Get the frame number of when to start the transition in
    ldh     a, [hFrameCounter]
    add     a, TRANSITION_DELAY
    ldh     [hTransitionIndex], a
    
    rst     JP_HL
    
.delayLoop
    rst     WaitVBlank
    ; Calling SoundSystem_Process directly instead of SoundUpdate
    ; because this is in ROM0 and there is no sync data to be looking
    ; for
    call    SoundSystem_Process
    call    MusicFadeOut
    ; Wait until the frame counter reaches
    ; Setup start frame + TRANSITION_DELAY
    ldh     a, [hFrameCounter]
    ld      b, a
    ldh     a, [hTransitionIndex]
    cp      a, b
    jr      nz, .delayLoop
    
    ; Start transitioning in
    ld      a, TRANSITION_STATE_IN
    ldh     [hTransitionState], a
    
    ; Animate this part in reverse
    ld      a, TransitionPosTable.end - TransitionPosTable - 1
    ldh     [hTransitionIndex], a
    
    ; Clear pending LYC interrupts
    ld      hl, rIF
    res     IEB_STAT, [hl]
    ; Re-enable LYC interrupts
    ASSERT LOW(rIE) == HIGH(rIF)
    ld      l, h
    set     IEB_STAT, [hl]
    
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
    ; Hide the window
    ld      a, SCRN_X + WX_OFS
    ldh     [rWX], a
    
    ; Turn the transition off
    ASSERT TRANSITION_STATE_OFF == 0
    xor     a, a
    ldh     [hTransitionState], a
    
    ldh     a, [hLYCResetIndex]
    ASSERT LYC_INDEX_NONE == -1
    inc     a
    jp      nz, SetUpNextLYC.getLYC
    
    ; No LYC interrupts -> disable them
    ld      hl, rIE
    res     IEB_STAT, [hl]
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
