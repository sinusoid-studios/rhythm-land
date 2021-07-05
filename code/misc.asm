INCLUDE "defines.inc"

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
