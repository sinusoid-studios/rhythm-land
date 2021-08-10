INCLUDE "constants/hardware.inc"
INCLUDE "constants/interrupts.inc"

SECTION "OAM Variables", HRAM

; Index of the first available OAM slot, for determining where to start
; hiding unused objects
hNextOAMSlot::
    DS 1

SECTION "Shadow OAM", WRAM0, ALIGN[8]

wShadowOAM::
    DS sizeof_OAM_ATTRS * OAM_COUNT

SECTION "OAM DMA Routine", ROM0

; Initiate an OAM DMA
; This routine is copied to HRAM (hOAMDMA)
; @param    a   HIGH(wShadowOAM)
; @param    c   LOW(rDMA)
; @param    b   (OAM_COUNT * sizeof_OAM_ATTRS) / DMA_LOOP_CYCLES + 1
OAMDMA::
    ldh     [c], a
.wait
    dec     b           ; 1 cycle
    jr      nz, .wait   ; 3 cycles
    ASSERT DMA_LOOP_CYCLES == 1 + 3
    ret
.end::

SECTION "OAM DMA", HRAM

hOAMDMA::
    DS OAMDMA.end - OAMDMA

SECTION "OAM Routines", ROM0

; Hide all objects in OAM by zeroing their Y positions
HideAllObjects::
    ld      hl, wShadowOAM
HideAllObjectsAtAddress::
    ld      d, OAM_COUNT
HideObjects:
    ld      bc, sizeof_OAM_ATTRS
    xor     a, a
.loop
    ld      [hl], a
    add     hl, bc
    dec     d
    jr      nz, .loop
    ret

SECTION "Hide Unused Objects", ROM0

; Hide objects starting at hNextOAMSlot
HideUnusedObjects::
    ldh     a, [hNextOAMSlot]
    ld      b, a
    ld      a, OAM_COUNT
    sub     a, b
    ret     z       ; Nothing to do
    ld      d, a
    
    ld      a, b
    ASSERT sizeof_OAM_ATTRS == 4
    add     a, a    ; a * 2
    add     a, a    ; a * 4 (sizeof_OAM_ATTRS)
    ld      l, a
    ld      h, HIGH(wShadowOAM)
    
    jp      HideObjects
