INCLUDE "defines.inc"

SECTION "Background Map Variables", HRAM

; Width and height, in tiles, of the current background map
hMapWidth::
    DS 1
hMapHeight::
    DS 1

; Bank number of the current background map
hMapBank::
    DS 1
; Pointer to the current background map
hMapPointer::
.low::
    DS 1
.high::
    DS 1

; Position, in pixels, of the viewport to the current background map
hMapXPos::
.low::
    DS 1
.high::
    DS 1
hMapYPos::
.low::
    DS 1
.high::
    DS 1

SECTION "Background Map Scrolling", ROM0

; Scroll the background map horizontally by an arbitrary pixel distance
; @param    de  Scroll distance
MapScrollX::
    ; Add scroll distance to map position
    ld      hl, hMapXPos
    ld      a, [hli]    ; Low byte
    add     a, e
    ld      b, a        ; Don't overwrite, save for comparing
    ld      a, [hl]     ; High byte
    adc     a, d
    ld      [hld], a    ; Okay to overwrite (not comparing high byte)
    
    ; Add scroll distance to hSCX
    ldh     a, [hSCX]
    add     a, e
    ldh     [hSCX], a
    
    ; Check if just scrolled past a tile boundary
    ld      a, [hl]     ; Old position
    and     a, ~7       ; Ignore pixel position (1 tile = 8 pixels)
    ld      [hl], b     ; Overwrite new position
    ld      b, a
    ld      a, [hli]    ; New position
    and     a, ~7       ; Ignore pixel position
    cp      a, b        ; Compare old and new *tile* positions
    ; Didn't scroll to a new tile, finished
    ret     z
    
    ; Theoretically, the above check would wrongly find that no tile
    ; boundary was crossed if the scroll distance is a multiple of 256.
    ; However, that's fine by me because a scroll distance greater than
    ; 255 or less than -255 is ridiculous.
    
    ; Scrolled to a new tile -> load a new column of tiles
    
    ; Check if gone past the end of the map
    bit     7, [hl]     ; High byte
    ; Gone too far left (into negative position)
    jr      nz, .negative
    
    ; Get X tile position
    ld      b, [hl]     ; High byte
    dec     l
    ld      a, [hli]    ; Low byte
.getPos
    srl     b
    rra                 ; pos / 2
    srl     b
    rra                 ; pos / 4
    srl     b
    rra                 ; pos / 8
    
    ld      b, a
    ldh     a, [hMapWidth]
    dec     a           ; Check for > instead of >=
    cp      a, b
    jr      nc, .posOk
    
    ; Gone too far right
    xor     a, a
    ld      [hld], a    ; High byte
    ld      [hl], a     ; Low byte
    jr      .posOk

.negative
    ldh     a, [hMapWidth]
    ld      b, 0
    add     a, a
    rl      b           ; pos * 2
    add     a, a
    rl      b           ; pos * 4
    add     a, a
    rl      b           ; pos * 8
    ; Add scroll distance
    add     a, e
    dec     l
    ld      [hli], a    ; Low byte
    ld      a, b
    adc     a, d
    ld      [hld], a    ; High byte
    
    ld      a, [hli]    ; Low byte
    ld      b, [hl]     ; High byte
    jr      .getPos

.posOk
    ld      a, b
    ; If X is 0 product will be 0
    and     a, a
    jr      z, .skipMultiply
    
    ld      c, a
    ldh     a, [hMapHeight]
    call    Multiply
    ld      e, l
    ld      d, h
    jr      .doneMultiply
.skipMultiply
    ld      de, 0
.doneMultiply
    ; de = x * height
    
    ; Get Y tile position
    ld      hl, hMapYPos
    ld      a, [hli]    ; Low byte
    ld      b, [hl]     ; High byte
    srl     b
    rra                 ; pos / 2
    srl     b
    rra                 ; pos / 4
    srl     b
    rra                 ; pos / 8
    
    ld      l, a
    ld      h, 0
    add     hl, de
    ; hl = x * height + y
    
    ldh     a, [hMapPointer.low]
    ld      e, a
    ldh     a, [hMapPointer.high]
    ld      d, a
    add     hl, de
    ld      e, l
    ld      d, h
    ; de = pointer to start of column of map data
    
    ; Save current bank to restore when finished
    ldh     a, [hCurrentBank]
    push    af
    
    ldh     a, [hMapBank]
    ldh     [hCurrentBank], a
    ld      [rROMB0], a
    
    ; Copy map data to the background map
    ldh     a, [hSCY]
    ; a = y * 8
    and     a, (SCRN_VY_B - 1) << 3
    ldh     [hScratch2], a
    ld      l, a
    ld      h, 0
    add     hl, hl      ; y * 16
    add     hl, hl      ; y * 32
    
    ldh     a, [hSCX]
    srl     a           ; x / 2
    srl     a           ; x / 4
    srl     a           ; x / 8
    and     a, SCRN_VX_B - 1
    ld      c, a
    ld      b, HIGH(_SCRN0)
    add     hl, bc
    ; hl = _SCRN0 + y * SCRN_VX_B + x
    
    ld      bc, SCRN_VX_B
    ; Loop count
    ld      a, SCRN_Y_B
    ldh     [hScratch1], a
.drawLoop
    ldh     a, [rSTAT]
    and     a, STATF_BUSY
    jr      nz, .drawLoop
    
    ld      a, [de]
    ld      [hl], a
    
    ldh     a, [hScratch1]
    dec     a
    jr      z, .finished
    ldh     [hScratch1], a
    
    inc     de
    ; Move to next row
    add     hl, bc
    ; Check if gone past the bottom of the background map (need to wrap
    ; back to the top)
    ldh     a, [hScratch2]
    inc     a       ; Y position
    cp      a, SCRN_VY_B
    jr      c, .noWrap
    
    push    de
    ld      de, -(SCRN_VY_B * SCRN_VX_B)
    add     hl, de
    pop     de
    
    xor     a, a
.noWrap
    ldh     [hScratch2], a
    jr      .drawLoop
    
.finished
    ; Restore bank
    pop     af
    ldh     [hCurrentBank], a
    ld      [rROMB0], a
    ret
