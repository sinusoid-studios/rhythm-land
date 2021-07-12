INCLUDE "defines.inc"

SECTION "VBlank Flag", HRAM

; Non-zero after a VBlank interrupt has occurred
hVBlankFlag::
    DS 1

SECTION "VBlank Interrupt Vector", ROM0[$0040]

    push    af
    ; Signal VBlank occurred
    ld      a, 1
    ldh     [hVBlankFlag], a
    jp      VBlankHandler
    
    ; Ensure no space is wasted
    ASSERT @ - $0040 == 8

SECTION "VBlank Interrupt Handler", ROM0

VBlankHandler:
    push    bc
    
    ld      a, HIGH(wShadowOAM)
    lb      bc, (OAM_COUNT * sizeof_OAM_ATTRS) / DMA_LOOP_CYCLES + 1, LOW(rDMA)
    call    hOAMDMA
    
    ldh     a, [hSCX]
    ldh     [rSCX], a
    ldh     a, [hSCY]
    ldh     [rSCY], a
    
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
    ld      a, [hPressedKeys]
    xor     a, b        ; a = keys that changed state
    and     a, b        ; a = keys that changed to pressed
    ld      [hNewKeys], a
    ld      a, b
    ld      [hPressedKeys], a
    
    ; Done reading
    ld      a, P1F_GET_NONE
    ldh     [rP1], a
    
    ; Bank was never changed, no need to restore
    
    pop     bc
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
    ; Just updating sound, which is interruptable
    ei
    
    push    af
    push    bc
    push    de
    push    hl
    
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
    ; (%11 + 1) & %11 == 0
    inc     a
    and     a, STAT_MODE_MASK
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
