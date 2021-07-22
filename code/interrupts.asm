INCLUDE "constants/hardware.inc"
INCLUDE "constants/other-hardware.inc"
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
    ASSERT @ - $0040 == 8

SECTION "VBlank Interrupt Handler", ROM0

VBlankHandler:
    ldh     a, [hSCY]
    ldh     [rSCY], a
    ; Allow the screen transition to override LCDC and palettes
    ldh     a, [hTransitionState]
    ASSERT TRANSITION_STATE_OFF == 0
    and     a, a
    jr      nz, .transition
    ldh     a, [hLCDC]
    ldh     [rLCDC], a
    ldh     a, [hBGP]
    ldh     [rBGP], a
    ldh     a, [hOBP0]
    ldh     [rOBP0], a
    ldh     a, [hOBP1]
    ldh     [rOBP1], a
.transition
    
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
    
    ldh     a, [hVBlankFlag]
    and     a, a
    jr      z, .normalReturn
    inc     a
    jr      z, .finished
    xor     a, a
    ldh     [hVBlankFlag], a
    ; Called from WaitVBlank -> return to caller of that function
    pop     bc
    pop     af
    jr      .return
.normalReturn
    ; a = 0
    dec     a
    ; Use -1 to make the flag non-zero but allow checking for it in
    ; order to know when to ignore a non-zero VBlank flag value
    ldh     [hVBlankFlag], a
.finished
    pop     bc
.return
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
    
    ldh     a, [rSTAT]
    and     a, STATF_LYCF
    jr      z, HBlankHandler
    
    ; Just updating sound, which is interruptable
    ei
    
    push    bc
    push    de
    push    hl
    
    ; Clear any previous music sync data
    xor     a, a
    ld      [wMusicSyncData], a
    
    ; Save current bank to restore when finished
    ldh     a, [hCurrentBank]
    push    af
    
    call    SoundSystem_Process
    
    ; Restore bank
    pop     af
    ldh     [hCurrentBank], a
    ld      [rROMB0], a
    
    pop     hl
    pop     de
    pop     bc
    
    di
    ; Return at the start of HBlank for any code that waits for VRAM to
    ; become accessible, since this interrupt handler might be called
    ; while waiting
:
    ; Wait for mode 3, which comes before HBlank
    ldh     a, [rSTAT]
    ASSERT (STATF_LCD + 1) & STAT_MODE_MASK == 0
    inc     a
    and     a, STAT_MODE_MASK
    ; If in mode 3, a = 0
    jr      nz, :-
    
:
    ; Wait for HBlank -> ensured the beginning of HBlank by above
    ldh     a, [rSTAT]
    and     a, STAT_MODE_MASK   ; HBlank = Mode 0
    jr      nz, :-
    
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

HBlankHandler:
    ld      a, [hScratch1]
    ldh     [rWX], a
    pop     af
    reti
