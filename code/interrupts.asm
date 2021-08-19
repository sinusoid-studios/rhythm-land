INCLUDE "constants/hardware.inc"
INCLUDE "constants/other-hardware.inc"
INCLUDE "constants/transition.inc"
INCLUDE "constants/interrupts.inc"
INCLUDE "macros/misc.inc"

SECTION "VBlank Flag", HRAM

; Non-zero after a VBlank interrupt has occurred
hVBlankFlag::
    DS 1

SECTION "VBlank Interrupt Vector", ROM0[$0040]

    push    af
    ldh     a, [hSCX]
    ldh     [rSCX], a
    jp      VBlankHandler
    
    ; Ensure no space is wasted
    ASSERT @ == $0048

SECTION "VBlank Interrupt Handler", ROM0

VBlankHandler:
    ldh     a, [hSCY]
    ldh     [rSCY], a
    ; Allow the screen transition to override LCDC
    ldh     a, [hTransitionState]
    ASSERT TRANSITION_STATE_OFF == 0
    and     a, a
    jr      nz, .transition
    ldh     a, [hLCDC]
    ldh     [rLCDC], a
.transition
    ldh     a, [hBGP]
    ldh     [rBGP], a
    ldh     a, [hOBP0]
    ldh     [rOBP0], a
    ldh     a, [hOBP1]
    ldh     [rOBP1], a
    
    ; Increment frame counter
    ldh     a, [hFrameCounter]
    inc     a
    ldh     [hFrameCounter], a
    
    ; Reset the extra LYC index
    ldh     a, [hLYCResetIndex]
    ldh     [hLYCIndex], a
    
    ; Set the next LYC value
    ld      a, TRANSITION_BLOCK_HEIGHT - 1
    push    hl
    call    SetUpNextLYCTransition.gotBlockLYC
    pop     hl
    
    push    bc
    
    ld      a, HIGH(wShadowOAM)
    lb      bc, (OAM_COUNT * sizeof_OAM_ATTRS) / DMA_LOOP_CYCLES + 1, LOW(rDMA)
    call    hOAMDMA
    
    ei      ; Timing-insensitive stuff follows
    
    ; Read the joypad
    
    ; Read D-Pad
    ld      a, P1F_GET_DPAD
    call    ReadPadNibble
    swap    a           ; Move directions to high nibble
    ld      b, a
    
    ; Read buttons
    ld      a, P1F_GET_BTN
    call    ReadPadNibble
    xor     a, b        ; Combine buttons and directions + complement
    ld      b, a
    
    ; Update hNewKeys
    ldh     a, [hPressedKeys]
    xor     a, b        ; a = keys that changed state
    ld      c, a        ; Save for hReleasedKeys
    and     a, b        ; a = keys that changed to pressed
    ldh     [hNewKeys], a
    ; Update hReleasedKeys
    ld      a, b        ; a = pressed keys
    cpl                 ; a = unpressed keys
    and     a, c        ; a = keys that changed to unpressed
    ldh     [hReleasedKeys], a
    
    ld      a, b
    ldh     [hPressedKeys], a
    
    ; Done reading
    ld      a, P1F_GET_NONE
    ldh     [rP1], a
    
    ; Bank was never changed, no need to restore
    
    pop     bc
    
    ldh     a, [hVBlankFlag]
    and     a, a
    jr      z, .finished
    xor     a, a
    ldh     [hVBlankFlag], a
    ; Called from WaitVBlank -> return to caller of that function
    ; af trashed (becomes return address)
    pop     af
.finished
    pop     af
    ret         ; Interrupts already enabled

SECTION "VBlank Interrupt Handler Joypad Reading", ROM0

; @param    a   Value to write to rP1
; @return   a   Reading from rP1, ignoring non-input bits (forced high)
ReadPadNibble:
    ldh     [rP1], a
    ; Burn 16 cycles between write and read
    call    .ret        ; 10 cycles
    ldh     a, [rP1]    ; 3 cycles
    ldh     a, [rP1]    ; 3 cycles
    ldh     a, [rP1]    ; Read
    or      a, $F0      ; Ignore non-input bits
.ret
    ret

SECTION "STAT Interrupt Vector", ROM0[$0048]

STATHandler:
    push    af
    push    bc
    push    hl
    
    ; If this interrupt is an extra LYC interrupt, go to its handler
    ldh     a, [hLYCFlag]
    and     a, a
    jr      nz, .extraLYC
    
    ; Need to set WX -> get current position
    ldh     a, [rLYC]
    inc     a       ; LYC offset by -1
.updateTransition
    ; Divide by 8 to get block index
    ASSERT TRANSITION_BLOCK_HEIGHT == 8
    ; a will be a multiple of 8
    rrca            ; a / 2
    rrca            ; a / 4
    ASSERT TRANSITION_BLOCK_DIFFERENCE == 2
    ; Multiplied by 2 to give a slightly more significant delay between
    ; blocks
    ; a / 8 * 2 == a / 4 & ~1 but that AND isn't necessary since A will
    ; be a multiple of 8 (8 & 1 == 0 already)
    ld      b, a    ; Save block index for setting up the next interrupt
    srl     b       ; Finish division by 8 for block index
    ; Offset block index by transition index
    ld      l, a
    ldh     a, [hTransitionIndex]
    add     a, l
    ; Check if this position is past the end of the table
    ASSERT HIGH(TransitionPosTable.end + (SCRN_Y / 8 * 2) - 1) == HIGH(TransitionPosTable)
    cp      a, LOW(TransitionPosTable.end)
    jr      c, .posOk
    ; Past the end of the table -> clamp to the end position
    ld      l, TRANSITION_END_POS   ; l = WX value
    jr      .waitHBlank
.posOk
    ASSERT LOW(TransitionPosTable) == 0
    ld      l, a
    ld      h, HIGH(TransitionPosTable)
    ; Read transition block position (WX value)
    ld      l, [hl]
.waitHBlank
    ; Wait for HBlank to set WX
    ldh     a, [rSTAT]
    ASSERT STATF_HBL == 0
    and     a, STAT_MODE_MASK
    jr      nz, .waitHBlank
    
    ld      a, l    ; l = WX value
    ldh     [rWX], a
    
    call    SetUpNextLYCTransition
    jr      InterruptReturn

.extraLYC
    ; Get the current screen's extra LYC interrupt handler
    ldh     a, [hCurrentScreen]
    add     a, a
    ASSERT LOW(LYCHandlerTable) == 0
    ld      l, a
    ASSERT HIGH(LYCHandlerTable.end - 1) == HIGH(LYCHandlerTable)
    ld      h, HIGH(LYCHandlerTable)
    ; Get the pointer to the handler
    ld      a, [hli]
    ld      h, [hl]
    ld      l, a
    ; Call it
    rst     JP_HL
    
    ; Check if currently transitioning
    ldh     a, [hTransitionState]
    ; Transition state bit 0:
    ; 0 = off OR midway setup and delay
    ; 1 = transitioning in OR transitioning out
    ASSERT TRANSITION_STATE_OUT & 1 == 1 && TRANSITION_STATE_IN & 1 == 1
    ASSERT TRANSITION_STATE_MID & 1 == 0 && TRANSITION_STATE_OFF & 1 == 0
    rra     ; Move bit 0 to carry
    jr      nc, .setUpNextLYC
    
    ; Find the next transition block's index for setting up the next
    ; interrupt
    ldh     a, [rLYC]
    inc     a   ; LYC offset by -1
    ld      b, a
    ; If a transition block also appears this scanline, update that as
    ; well
    and     a, TRANSITION_BLOCK_HEIGHT - 1
    ld      a, b
    jr      z, .updateTransition
    
    ; Set up the next block's interrupt
    ; Divide by 8 to get block index
    ASSERT TRANSITION_BLOCK_HEIGHT == 8
    rrca        ; a / 2
    rrca        ; a / 4
    rrca        ; a / 8
    and     a, %00011111
    ld      b, a    ; SetUpNextLYCTransition expects block index in b
    
    call    SetUpNextLYCTransition
    jr      InterruptReturn

.setUpNextLYC
    call    SetUpNextLYC
    ; Fall-through

InterruptReturn:
    pop     hl
    pop     bc
    ; Return at the start of HBlank for any code that waits for VRAM to
    ; become accessible, since this interrupt handler might be called
    ; while waiting
.waitMode3
    ; Wait for mode 3, which comes before HBlank
    ldh     a, [rSTAT]
    ASSERT (STATF_LCD + 1) & STAT_MODE_MASK == 0
    inc     a
    and     a, STAT_MODE_MASK
    ; If in mode 3, a = 0
    jr      nz, .waitMode3
    
.waitHBlank
    ; Wait for HBlank -> ensured the beginning of HBlank by above
    ldh     a, [rSTAT]
    ASSERT STATF_HBL == 0
    and     a, STAT_MODE_MASK
    jr      nz, .waitHBlank
    
    ; This interrupt handler should return with at least 20 cycles left
    ; of accessible VRAM, which is what any VRAM accessibility-waiting
    ; code would assume it has
    
    ; Remaining time = Minimum HBlank time - 2 instructions above + Mode 2 time
    ;                = 22 cycles - 4 cycles + 20 cycles
    ;                = 38 cycles
    
    pop     af  ; 3 cycles
    reti        ; 4 cycles
    
    ; Minimum 31 remaining VRAM-accessible cycles
    
    ; Not waiting for specifically the beginning of HBlank (i.e. just
    ; waiting for HBlank) would result in a minimum of
    ; 20 - 7 (pop + reti) = only 13 cycles!!!

SECTION "Set Up Next LYC Interrupt During Transition", ROM0

SetUpNextLYCTransition:
    ; Get next transition block's LYC value
    ASSERT LOW(TransitionBlockLYCTable) == 0
    ld      l, b    ; b = block index
    ld      h, HIGH(TransitionBlockLYCTable)
    ld      a, [hl]
.gotBlockLYC
    ldh     [rLYC], a
    
    ; Reset extra LYC interrupt flag
    xor     a, a
    ldh     [hLYCFlag], a
    
    ; Check for extra LYC interrupts
    ldh     a, [hLYCIndex]
    ASSERT LYC_INDEX_NONE == -1
    inc     a
    ret     z
    dec     a   ; Undo inc
    ; Get next LYC value
    ASSERT LOW(LYCTable) == 0
    ld      l, a
    ASSERT HIGH(LYCTable.end - 1) == HIGH(LYCTable)
    ld      h, HIGH(LYCTable)
    ; If there are no more extra LYC values for the frame, the
    ; transition wins
    ld      a, [hl]
    ASSERT LYC_FRAME_END == -1
    inc     a
    jr      z, .frameEnd
    ; Compare with the next transition block's LYC value so the earlier
    ; one goes first
    ldh     a, [rLYC]
    cp      a, [hl]
    ret     c
    ; The extra LYC interrupt comes before the next transition block
    ld      a, [hl]
    ldh     [rLYC], a
    ; Move on to the next LYC
    ld      hl, hLYCIndex
    inc     [hl]
    ; Set the extra LYC interrupt flag
    ASSERT hLYCFlag == hLYCIndex - 1
    dec     l
    ld      [hl], h     ; Non-zero
    ret

.frameEnd
    ; Set the LYC index to none to speed up checking a bit
    ASSERT LYC_INDEX_NONE == LYC_FRAME_END
    dec     a   ; Undo inc
    ldh     [hLYCIndex], a
    ret

SECTION "Set Up Next Extra LYC Interrupt", ROM0

SetUpNextLYC:
    ; Check for extra LYC interrupts
    ldh     a, [hLYCIndex]
    ASSERT LYC_INDEX_NONE == -1
    inc     a
    ret     z
.getLYC::
    dec     a   ; Undo inc
    ; Get next LYC value
    ASSERT LOW(LYCTable) == 0
    ld      l, a
    ASSERT HIGH(LYCTable.end - 1) == HIGH(LYCTable)
    ld      h, HIGH(LYCTable)
    ; Check if there are no more extra LYC values for the frame
    ld      a, [hl]
    ASSERT LYC_FRAME_END == -1
    inc     a
    ret     z
    dec     a   ; Undo inc
    ldh     [rLYC], a
    ; Move on to the next LYC
    ld      hl, hLYCIndex
    inc     [hl]
    ; Set the extra LYC interrupt flag
    ASSERT hLYCFlag == hLYCIndex - 1
    dec     l
    ld      [hl], h     ; Non-zero
    ret
