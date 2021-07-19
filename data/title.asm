INCLUDE "defines.inc"

DEF CHANGE EQU (TITLE_SCROLL_END_POS - TITLE_SCROLL_START_POS) << 16
DEF START EQU TITLE_SCROLL_START_POS << 16

SECTION "Title Screen Scroll Position Table", ROM0

; Quadratic ease-in
; Formula from <https://gizma.com/easing>
TitleScrollPosTable::
    FOR TIME, 1, TITLE_SCROLL_DURATION + 1
        DEF TIME_FRACTION = DIV(TIME << 16, TITLE_SCROLL_DURATION << 16)/*  - 1.0 */
        ; DEF VALUE = (MUL(-CHANGE, POW(TIME_FRACTION, 4.0) - 1.0) + START) >> 16
        DEF VALUE = (MUL(CHANGE, POW(TIME_FRACTION, 2.0)) + START) >> 16
        ; Since the start and end positions are set before and after the
        ; scroll anyway, it's not necessary to include them in this
        ; table.
        IF VALUE != TITLE_SCROLL_START_POS && VALUE != TITLE_SCROLL_END_POS
            DB VALUE
        ENDC
    ENDR
    DB TITLE_SCROLL_END_POS
.end::
