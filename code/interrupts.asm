INCLUDE "constants/hardware.inc"
INCLUDE "constants/other-hardware.inc"
INCLUDE "constants/engine.inc"
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
    
    push    bc
    
    ld      a, HIGH(wShadowOAM)
    lb      bc, (OAM_COUNT * sizeof_OAM_ATTRS) / DMA_LOOP_CYCLES + 1, LOW(rDMA)
    call    hOAMDMA
    
    ei      ; Timing-insensitive stuff follows
    
    ; Read the joypad
    
    ; Read D-Pad
    ld      a, P1F_GET_DPAD
    call    .readPadNibble
    swap    a           ; Move directions to high nibble
    ld      b, a
    
    ; Read buttons
    ld      a, P1F_GET_BTN
    call    .readPadNibble
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

; @param    a   Value to write to rP1
; @return   a   Reading from rP1, ignoring non-input bits (forced high)
.readPadNibble
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
    
    ; If this interrupt is for the sound update (LYC=0), go do that
    ldh     a, [rLYC]
    and     a, a
    jp      z, UpdateSound
    
    ld      l, a    ; Save for use in transition update
    ; If this interrupt is an extra LYC interrupt, go to its handler
    ldh     a, [hLYCFlag]
    and     a, a
    jr      nz, .extraLYC
    
    ; Need to set WX -> get current position
    ld      a, l    ; a = [rLYC]
    inc     a       ; LYC offset by -1
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
    
.setupNextInterrupt
    ; Get next transition block's LYC value
    ASSERT LOW(TransitionBlockLYCTable) == 0
    ld      l, b    ; b = block index
    ld      h, HIGH(TransitionBlockLYCTable)
    ld      a, [hl]
    ldh     [rLYC], a
    ; If the sound update is next, no need to check for extra LYC
    ; interrupts
    and     a, a
    jr      z, InterruptReturn
    
    ; Reset extra LYC interrupt flag for non-sound update interrupt
    xor     a, a
    ldh     [hLYCFlag], a
    ; Check for extra LYC interrupts
    ldh     a, [hLYCIndex]
    ASSERT LYC_INDEX_NONE == -1
    inc     a
    jr      z, InterruptReturn
    dec     a   ; Undo inc
    ; Get next LYC value
    ASSERT LOW(STARTOF("LYC Value Table")) == 0
    ld      l, a
    ld      h, HIGH(STARTOF("LYC Value Table"))
    ; Compare with the next transition block's LYC value so the earlier
    ; one goes first
    ldh     a, [rLYC]
    cp      a, [hl]
    jr      c, InterruptReturn
    ; The extra LYC interrupt comes before the next transition block
    ld      a, [hli]
    ldh     [rLYC], a
    ld      a, [hl]     ; Get next extra LYC value
    ; Move on to the next LYC
    ld      hl, hLYCIndex
    inc     [hl]
    ; Set the extra LYC interrupt flag
    ASSERT hLYCFlag == hLYCIndex - 1
    dec     l
    ld      [hl], h     ; Non-zero
    ; Check if the next extra LYC value is the reset value
    ASSERT LYC_RESET == -1
    inc     a
    jr      nz, InterruptReturn
    ; The next extra LYC value is the reset value -> reset LYC index
    ldh     a, [hLYCResetIndex]
    ldh     [hLYCIndex], a
    jr      InterruptReturn

.extraLYC
    ; Get the current screen's extra LYC interrupt handler
    ldh     a, [hCurrentScreen]
    add     a, a
    ASSERT LOW(LYCHandlerTable) == 0 && HIGH(LYCHandlerTable.end - 1) == HIGH(LYCHandlerTable)
    ld      l, a
    ld      h, HIGH(LYCHandlerTable)
    ; Get the pointer to the handler
    ld      a, [hli]
    ld      h, [hl]
    ld      l, a
    ; Call it
    rst     JP_HL
    
    ; Find the next transition block's index for setting up the next
    ; interrupt
    ldh     a, [rLYC]
    inc     a   ; LYC offset by -1
    ; Divide by 8 to get block index
    ASSERT TRANSITION_BLOCK_HEIGHT == 8
    rrca        ; a / 2
    rrca        ; a / 4
    rrca        ; a / 8
    and     a, %00011111
    ld      b, a    ; .setupNextInterrupt expects block index in b
    jr      .setupNextInterrupt

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

SECTION "Sound Update Interrupt Handler", ROM0

UpdateSound:
    ; Check if currently transitioning
    ldh     a, [hTransitionState]
    ; Transition state bit 0:
    ; 0 = off OR midway setup and delay
    ; 1 = transitioning in OR transitioning out
    ASSERT TRANSITION_STATE_OUT & 1 == 1 && TRANSITION_STATE_IN & 1 == 1
    ASSERT TRANSITION_STATE_MID & 1 == 0 && TRANSITION_STATE_OFF & 1 == 0
    rra     ; Move bit 0 to carry
    jr      nc, .noTransition
    ; Set up next interrupt
    ld      a, TRANSITION_BLOCK_HEIGHT - 1
    ldh     [rLYC], a
.noTransition
    ldh     a, [hLYCIndex]
    ASSERT LYC_INDEX_NONE == -1
    inc     a
    jr      z, .noSetLYC
    dec     a
    ASSERT LOW(STARTOF("LYC Value Table")) == 0
    ld      l, a
    ld      h, HIGH(STARTOF("LYC Value Table"))
    ld      a, [hli]
    ldh     [rLYC], a
    ld      a, [hl]
    ld      hl, hLYCIndex
    inc     [hl]
    ASSERT hLYCFlag == hLYCIndex - 1
    dec     l
    ld      [hl], h     ; Non-zero
    ASSERT LYC_RESET == -1
    inc     a
    jr      nz, .noSetLYC
    ldh     a, [hLYCResetIndex]
    ldh     [hLYCIndex], a
.noSetLYC
    
    ; Just updating sound, which is interruptable
    ei
    
    push    de
    
    ; Clear any previous music sync data
    ld      a, SYNC_NONE
    ld      [wMusicSyncData], a
    
    ; Save current bank to restore when finished
    ldh     a, [hCurrentBank]
    push    af
    
    call    SoundSystem_Process
    
    ; Restore bank
    pop     af
    ldh     [hCurrentBank], a
    ld      [rROMB0], a
    
    pop     de
    di
    jp      InterruptReturn
