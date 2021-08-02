INCLUDE "constants/hardware.inc"
INCLUDE "constants/other-hardware.inc"
INCLUDE "constants/engine.inc"
INCLUDE "constants/transition.inc"
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
    push    hl
    
    ldh     a, [rLYC]
    and     a, a
    jr      z, .updateSound
    
    ; Need to set WX -> get current position
    inc     a       ; LYC offset by -1
    ; Divide by 8 to get block index
    ASSERT TRANSITION_BLOCK_HEIGHT == 8
    ; a will be a multiple of 8
    rrca        ; a / 2
    rrca        ; a / 4
    ASSERT TRANSITION_BLOCK_DIFFERENCE == 2
    ; Multiplied by 2 to give a slightly more significant delay between
    ; blocks
    ; a / 8 * 2 == a / 4 & ~1 but that AND isn't necessary since a will
    ; be a multiple of 8 (8 & 1 == 0 already)
    ASSERT LOW(TransitionPosTable) == 0
    ld      l, a
    ldh     a, [hTransitionIndex]
    add     a, l
    ; Check if this position is past the end of the table
    ASSERT HIGH(TransitionPosTable.end + (SCRN_Y / 8 * 2) - 1) == HIGH(TransitionPosTable)
    cp      a, LOW(TransitionPosTable.end)
    jr      c, .posOk
    ; Past the end of the table -> clamp to the end position
    ld      l, TRANSITION_END_POS
    jr      .waitHBlank
.posOk
    ld      l, a
    ld      h, HIGH(TransitionPosTable)
    ld      l, [hl]
.waitHBlank
    ; Wait for HBlank to set WX
    ldh     a, [rSTAT]
    ASSERT STATF_HBL == 0
    and     a, STAT_MODE_MASK
    jr      nz, .waitHBlank
    
    ld      a, l    ; l = WX value
    ldh     [rWX], a
    
    ; Set up next interrupt
    ldh     a, [rLYC]
    add     a, TRANSITION_BLOCK_HEIGHT
    cp      a, SCRN_Y - 1
    jr      nc, .nextFrame
    ldh     [rLYC], a
    jr      InterruptReturn
.nextFrame
    xor     a, a
    ldh     [rLYC], a
    jr      InterruptReturn

.updateSound
    ; Check if currently transitioning
    ldh     a, [hTransitionState]
    ; Transition state bit 0:
    ; 0 = off OR midway setup and delay
    ; 1 = transitioning in OR transitioning out
    ASSERT TRANSITION_STATE_IN & 1 == 1 && TRANSITION_STATE_OUT & 1 == 1
    ASSERT TRANSITION_STATE_MID & 1 == 0 && TRANSITION_STATE_OFF & 1 == 0
    rra     ; Move bit 0 to carry
    jr      nc, .noTransition
    ; Set up next interrupt
    ld      a, TRANSITION_BLOCK_HEIGHT - 1
    ldh     [rLYC], a
.noTransition
    ; Just updating sound, which is interruptable
    ei
    
    push    bc
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
    pop     bc
    ; Fall-through

InterruptReturn:
    pop     hl
    di
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
    ;                = 21 cycles - 4 cycles + 20 cycles
    ;                = 37 cycles
    
    pop     af  ; 3 cycles
    reti        ; 4 cycles
    
    ; 30 remaining VRAM-accessible cycles
    
    ; Not waiting for specifically the beginning of HBlank (i.e. just
    ; waiting for HBlank) would result in 20 - 7 (pop + reti) = only 13
    ; cycles!!!
