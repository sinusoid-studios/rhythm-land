INCLUDE "constants/hardware.inc"

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

; X position, in pixels, of the viewport to the current background map
hMapXPos::
.low::
    DS 1
.high::
    DS 1
; Y position, in tiles, of the viewport the the current background map
hMapTileYPos::
    DS 1

; Number of tiles to copy to the edge of the screen if a tile boundary
; is crossed
hMapUpdateHeight::
    DS 1

; SCX and SCY values, but not hSCX and hSCY because they shouldn't be
; copied to rSCX and rSCY
; The game must set hSCX and hSCY appropriately itself
hMapSCX::
    DS 1
hMapSCY::
    DS 1

SECTION "Background Map Drawing", ROM0

; Draw the entire visible portion of the map onto the background map,
; for use during setup
MapDraw::
    ; Reset scroll
    xor     a, a
    ldh     [hMapSCX], a
    ldh     [hMapSCY], a
    
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
    ldh     a, [hMapSCX]
    add     a, 8
    ldh     [hMapSCX], a
    inc     b
    dec     c
    jr      nz, .loop
    
    ; Reset modified X scroll
    xor     a, a
    ldh     [hMapSCX], a
    ret

SECTION "Background Map Scrolling", ROM0

; Scroll the background map to the left
; WARNING: A scroll distance of more than 8 pixels will not work
; properly, as only a single column of tiles is copied when a tile
; boundary is crossed
; @param    b   Scroll distance, in pixels
MapScrollLeft::
    ; Update hMapSCX
    ldh     a, [hMapSCX]
    sub     a, b
    ldh     [hMapSCX], a
    
    ; Update map position
    ld      hl, hMapXPos
    ld      a, [hl] ; Low byte
    sub     a, b
    ld      b, [hl] ; Save old position for comparing
    ld      [hli], a
    jr      nc, .noBorrow
    dec     [hl]    ; High byte
.noBorrow
    ; Check if just scrolled past a tile boundary
    ; Ignore pixel bits -> looking at which tile
    and     a, ~7
    ; A tile boundary has been crossed if the new tile bits don't match
    ; the old tile bits
    ld      c, a
    ld      a, b    ; b = old position
    and     a, ~7
    ; Check if old and new tile positions are the same
    cp      a, c
    ; Didn't scroll to a new tile, finished
    ret     z
    
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
    ld      c, a
    ; Adjust position with previous underflow
    dec     l
    ld      a, [hli]    ; Low byte
    ld      h, [hl]     ; High byte
    ld      l, a
    add     hl, bc
    ld      a, h
    ldh     [hMapXPos.high], a
    ld      a, l
    ldh     [hMapXPos.low], a
    ld      b, h
    ; a = low byte, b = high byte
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
    ldh     a, [hMapTileYPos]
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
    ld      [rROMB0], a
    
    ; Copy map data to the background map
    ldh     a, [hMapSCY]
    rrca    ; y / 2
    rrca    ; y / 4
    rrca    ; y / 8
    and     a, SCRN_VY_B - 1
    ; a = tile y
    ldh     [hScratch2], a
    add     a, a    ; tile y * 2
    add     a, a    ; tile y * 4
    add     a, a    ; tile y * 8
    ld      l, a
    ld      h, 0
    add     hl, hl  ; tile y * 16
    add     hl, hl  ; tile y * 32
    
    ldh     a, [hMapSCX]
    rrca    ; x / 2
    rrca    ; x / 4
    rrca    ; x / 8
    and     a, SCRN_VX_B - 1
    ; a = tile x
    ld      c, a
    ld      b, HIGH(_SCRN0)
    add     hl, bc
    ; hl = _SCRN0 + y * SCRN_VX_B + x
    
    ld      bc, SCRN_VX_B
    ; Loop count
    ldh     a, [hMapUpdateHeight]
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
