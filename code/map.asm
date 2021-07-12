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

SECTION "Background Map Drawing", ROM0

; Draw the entire visible portion of the map onto the background map,
; for use during setup
MapDraw::
    ; Reset scroll
    xor     a, a
    ldh     [hSCX], a
    
    ; Get X tile position
    ld      hl, hMapXPos
    ld      a, [hli]    ; Low byte
    ld      b, [hl]     ; High byte
.getPos
    srl     b
    rra                 ; pos / 2
    srl     b
    rra                 ; pos / 4
    srl     b
    rra                 ; pos / 8
    
    ; Draw every column on the screen
    ld      c, SCRN_X_B
    ld      b, a
.loop
    push    bc
    ld      a, b
    call    MapDrawColumn.posOk
    pop     bc
    ldh     a, [hSCX]
    add     a, 8
    ldh     [hSCX], a
    inc     b
    dec     c
    jr      nz, .loop
    
    ; Reset scroll again
    xor     a, a
    ldh     [hSCX], a
    ret

SECTION "Background Map Scrolling", ROM0

; Scroll the background map to the left by 1 pixel
MapScrollLeft::
    ; Update hSCX
    ldh     a, [hSCX]
    dec     a
    ldh     [hSCX], a
    
    ; Update map position
    ld      hl, hMapXPos
    ld      a, [hl]     ; Low byte
    sub     a, LOW(1)
    ld      [hli], a
    jr      nc, .noBorrow
    dec     [hl]        ; High byte
.noBorrow
    ; Check if just scrolled past a tile boundary
    ; Ignore non-pixel bits ("tile bits")
    or      a, ~7
    ; If just moved to the next tile (%XXXXX000 -> %XXXXX111), a should
    ; now be %11111111, increment to get 0 if scrolled to new tile
    inc     a
    ; Didn't scroll to a new tile, finished
    ret     nz
    
    ; Scrolled to a new tile -> load a new column of tiles
    
    ; Check if gone past the end of the map
    bit     7, [hl]     ; High byte
    ; Gone too far
    jp      z, MapDrawColumn
    jp      MapDrawColumn.negative

SECTION "Background Map Column Drawing", ROM0

; @param    hl  hMapXPos.high
MapDrawColumn:
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
    ; Scroll a pixel left
    sub     a, LOW(1)
    dec     l
    ld      [hli], a    ; Low byte
    ld      a, b
    sbc     a, HIGH(1)
    ld      [hld], a    ; High byte
    
    ld      a, [hli]    ; Low byte
    ld      b, [hl]     ; High byte
    jr      .getPos

.posOk
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
