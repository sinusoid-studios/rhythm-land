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
