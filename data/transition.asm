INCLUDE "constants/hardware.inc"
INCLUDE "constants/transition.inc"

DEF CHANGE EQU (TRANSITION_END_POS - TRANSITION_START_POS) << 16
DEF START EQU TRANSITION_START_POS << 16

SECTION "Screen Transition Window Position Table", ROM0, ALIGN[8]

; Exponential ease-in
; Formula from <https://gizma.com/easing>
TransitionPosTable::
    ; Extra values for blocks above the bottom one (transition starts
    ; from the bottom of the screen)
    REPT (SCRN_Y_B * TRANSITION_BLOCK_DIFFERENCE) - 1
        DB TRANSITION_START_POS
    ENDR
    
    FOR TIME, 1, TRANSITION_DURATION + 1
        DEF TIME_FRACTION = DIV(TIME << 16, TRANSITION_DURATION << 16)
        DEF VALUE = (MUL(CHANGE, POW(2.0, MUL(10.0, TIME_FRACTION - 1.0))) + START) >> 16
        ; WX=166 doesn't work properly due to hardware bugs, and there
        ; isn't much to do about it but skip that value entirely.
        ; Also, since the start and end positions are set before and
        ; after the transition anyway, it's not necessary to include
        ; them in this table.
        IF VALUE != 166 && VALUE != TRANSITION_START_POS && VALUE != TRANSITION_END_POS
            DB VALUE
        ENDC
    ENDR
.end::
