INCLUDE "defines.inc"

SECTION "Screen Transition", ROM0

; Start a screen transition and wait for it to complete
; The next screen will be set up when the screen is fully covered
; @param    a   Game ID of the next screen
Transition::
    ; Save next screen's game ID
    ldh     [hCurrentGame], a
    
    ; Set initial music fade delay (use hScratch3 for it)
    ld      a, TRANSITION_MUSIC_FADE_SPEED
    ldh     [hScratch3], a
    
    ; Signal transition coming on
    xor     a, a
    ldh     [hScratch2], a
    
    ; Window always filling the screen vertically
    ; a = 0
    ldh     [rWY], a
    ; Hide the window initially
    ld      a, SCRN_X + 7
    ldh     [rWX], a
    ; Use hScratch1 for giving the HBlank interrupt handler the value to
    ; write to rWX
    ldh     [hScratch1], a
    
    ld      de, TransitionPosTable

; @param    de  Base pointer to the current position in the transition
.animate
    ; Enable the window
    ld      hl, rLCDC
    set     LCDCB_WIN, [hl]
    
    ; Enable the HBlank (Mode 0) interrupt
    ld      l, LOW(rSTAT)
    set     STATB_MODE00, [hl]
    
    ; hl used as pointer to current position for each block,
    ; recalculated for each block
    ASSERT HIGH(TransitionPosTable.end) == HIGH(TransitionPosTable)
    ld      h, d
    ; The final position of the window, for when the pointer to the
    ; current position is past the end of the table
    ; Store it in a free register because there's no reason not to
    ld      c, TRANSITION_END_POS
.loop
    halt
    ldh     a, [hVBlankFlag]
    and     a, a
    jr      z, .nextScanline
    xor     a, a
    ldh     [hVBlankFlag], a
    
    ; Advance the transition
    ; Get transition direction
    ldh     a, [hScratch2]
    and     a, a
    jr      nz, .comingOff
    
    ; Transition is coming on
    ASSERT HIGH(TransitionPosTable.end) == HIGH(TransitionPosTable)
    inc     e
    ; Check if this part of the transition is over
    ld      a, e
    cp      a, LOW(TransitionPosTable.end)
    jr      nc, .covered
    
    ; Set first block's position before LY 0
    ld      a, [de]
    ldh     [hScratch1], a
    ldh     [rWX], a
    
    ; This must also be called when the transition is coming off if it
    ; cuts into that time
    ASSERT TRANSITION_MUSIC_FADE_SPEED * 8 <= TRANSITION_DURATION + TRANSITION_DELAY
    call    MusicFadeOut
    jr      .loop

.covered
    ; The screen is now entirely covered, so setup for the next screen
    ; can be done!
    
    ; Disable the HBlank (Mode 0) interrupt
    ld      hl, rSTAT
    res     STATB_MODE00, [hl]
    
    ; Set all actors to empty
    ld      a, ACTOR_EMPTY
    ld      hl, wActorTypeTable
    ld      c, MAX_NUM_ACTORS
    rst     MemsetSmall
    
    ; Get next screen's game ID
    ldh     a, [hCurrentGame]
    ld      b, a
    add     a, a    ; a * 2 (Pointer)
    add     a, b    ; a * 3 (+Bank)
    add     a, LOW(GameSetupTable)
    ld      l, a
    adc     a, HIGH(GameSetupTable)
    sub     a, l
    ld      h, a
    
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
    ld      c, TRANSITION_DELAY
.delayLoop
    rst     WaitVBlank
    call    MusicFadeOut
    dec     c
    jr      nz, .delayLoop
    
    ; Start moving the transition off
    ld      a, 1
    ldh     [hScratch2], a
    
    ; Animate this part in reverse
    ld      de, TransitionPosTable.end - 1
    jr      .animate

.comingOff
    ; Transition is coming off
    ASSERT HIGH(TransitionPosTable.end) == HIGH(TransitionPosTable)
    dec     e
    ; Check if this part of the transition is over
    ld      a, e
    ASSERT LOW(TransitionPosTable) == 0
    inc     a
    jr      z, .finished
    
    ; Set first block's position before LY 0
    ld      a, [de]
    ldh     [hScratch1], a
    ldh     [rWX], a
    jr      .loop

.nextScanline
    ; Only update position after every tile
    ldh     a, [rLY]
    ld      b, a
    and     a, 7
    ; Not at the start of a tile -> nothing to do
    jr      nz, .loop
    
    ; Find the correct position to use based on current scanline
    ld      a, b    ; b = LY
    srl     a       ; a / 2
    srl     a       ; a / 4
    ASSERT TRANSITION_BLOCK_DIFFERENCE == 2
    and     a, ~1   ; a / 8 * 2
    ; Multiplied by 2 to give a slightly more significant delay between
    ; blocks
    add     a, e
    ASSERT HIGH(TransitionPosTable.end - 1 + (SCRN_Y / 8 * 2)) == HIGH(TransitionPosTable)
    cp      a, LOW(TransitionPosTable.end)
    jr      nc, .end
    
    ld      l, a
    ; Set position for HBlank interrupt handler to use
    ld      a, [hl]
    ldh     [hScratch1], a
    jr      .loop

.end
    ; This block has gone through all of the points in the ease, use the
    ; stick to the final position
    ld      a, c
    ldh     [hScratch1], a
    jr      .loop

.finished
    ; Disable the HBlank (Mode 0) interrupt
    ld      hl, rSTAT
    res     STATB_MODE00, [hl]
    
    ; Jump into the next screen's loop
    ldh     a, [hCurrentGame]
    ld      b, a
    add     a, a    ; a * 2 (Pointer)
    add     a, b    ; a * 3 (+Bank)
    add     a, LOW(GameTable)
    ld      l, a
    ASSERT HIGH(GameTable.end - 1) == HIGH(GameTable)
    ld      h, HIGH(GameTable)
    
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
    ldh     a, [hScratch3]
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
    push    bc
    push    de
    call    Music_Pause
    pop     de
    pop     bc
    ASSERT HIGH(TransitionPosTable.end) == HIGH(TransitionPosTable)
    ld      h, d
    ; Reset master volume to max, excluding VIN signal
    ld      a, $FF ^ (AUDVOL_VIN_LEFT | AUDVOL_VIN_RIGHT)
    ldh     [rNR50], a
    ; Countdown will become -1 next frame
    ASSERT LOW(-1) > TRANSITION_DURATION - TRANSITION_MUSIC_FADE_SPEED * 8
    xor     a, a
.noDecrease
    ldh     [hScratch3], a
    ret
