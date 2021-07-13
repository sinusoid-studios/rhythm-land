INCLUDE "defines.inc"

SECTION "RST $00", ROM0[$0000]

JP_HL::
    jp      hl

SECTION "RST $08", ROM0[$0008]

; Copy a block of memory from one place to another, even if the LCD is
; on
; @param    de  Pointer to beginning of block to copy
; @param    hl  Pointer to destination
; @param    bc  Number of bytes to copy
LCDMemcopy::
    ; Increment B if C is non-zero
    dec     bc
    inc     c
    inc     b
.loop
    ldh     a, [rSTAT]
    and     a, STATF_BUSY
    jr      nz, .loop
    ld      a, [de]
    ld      [hli], a
    inc     de
    dec     c
    jr      nz, .loop
    dec     b
    jr      nz, .loop
    ret

SECTION "RST $20", ROM0[$0020]

; Fill an arbitrary number of bytes with the same value
; @param    a   Value to fill with
; @param    hl  Pointer to destination
; @param    c   Number of bytes to fill
MemsetSmall::
    ld      [hli], a
    dec     c
    jr      nz, MemsetSmall
    ret

SECTION "RST $28", ROM0[$0028]

; Copy a block of memory from one place to another
; @param    de  Pointer to beginning of block to copy
; @param    hl  Pointer to destination
; @param    c   Number of bytes to copy
MemcopySmall::
    ld      a, [de]
    ld      [hli], a
    inc     de
    dec     c
    jr      nz, MemcopySmall
    ret

SECTION "RST $30", ROM0[$0030]

; Wait for a VBlank interrupt to occur
; The VBlank interrupt handler will return to the caller of this
; function once it is finished
WaitVBlank::
    ld      a, 1
    ldh     [hVBlankFlag], a
.loop
    halt
    jr      .loop

SECTION "Draw Hex", ROM0

; @param    a   Value to draw
; @param    hl  Pointer to destination on map
LCDDrawHex::
    ld      b, a
.waitVRAM
    ldh     a, [rSTAT]
    and     a, STATF_BUSY
    jr      nz, .waitVRAM
    
    ld      a, b        ; 1 cycle
    swap    a           ; 2 cycles
    and     a, $0F      ; 2 cycles
    ld      [hli], a    ; 2 cycles
    ld      a, b        ; 1 cycle
    and     a, $0F      ; 2 cycles
    ld      [hli], a    ; 2 cycles
    ; Total 12 cycles
    ret

SECTION "Multiply u8 by u8", ROM0

; Original code copyright 2017-2018 Antonio Niño Díaz
; (AntonioND/SkyLyrac)
; Taken from µCity <https://github.com/AntonioND/ucity>
; Modified slightly in this file

; Multiply a by c and store the result in hl
; @param    a   Multiplicand (unsigned)
; @param    c   Multiplier (unsigned)
; @return   hl  Product (unsigned)
Multiply::
    ld      b, 0
    ld      h, a
    ld      l, b
    
    ; Add (c * current bit place value) to product for every set bit in a
    REPT 8 - 1
    add     hl, hl
    jr      nc, .skip\@
    add     hl, bc
.skip\@
    ENDR
    
    ; Use conditional return instead of jump for the last bit
    add     hl, hl
    ret     nc
    add     hl, bc
    ret
