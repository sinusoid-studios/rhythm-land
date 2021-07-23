INCLUDE "constants/hardware.inc"
INCLUDE "constants/title.inc"

SECTION "Title Screen Scroll Position Table", ROM0

DEF CHANGE EQU (TITLE_SCROLL_END_POS - TITLE_SCROLL_START_POS) << 16
DEF START EQU TITLE_SCROLL_START_POS << 16

; Modified bounce ease-out
; Original formula from <http://robertpenner.com/easing/penner_easing_as1.txt>
; Modified to bounce 1 time fewer and fall for longer
TitleScrollPosTable::
    DEF TOTAL EQU 2.75
    DEF TOTAL_SQUARED EQU POW(TOTAL, 2.0)
    ; Part 1 - Fall
    DEF FALL_END EQU 1.8
    DEF FALL_END_FRACTION EQU DIV(FALL_END, TOTAL)
    ; Part 2 - Bounce 1
    DEF BOUNCE_1_END EQU 2.5
    DEF BOUNCE_1_END_FRACTION EQU DIV(BOUNCE_1_END, TOTAL)
    DEF BOUNCE_1_PEAK EQU FALL_END + DIV(BOUNCE_1_END - FALL_END, 2.0)
    DEF BOUNCE_1_PEAK_FRACTION EQU DIV(BOUNCE_1_PEAK, TOTAL)
    DEF BOUNCE_1_OFFSET EQU 1.0 - POW(DIV(BOUNCE_1_END - FALL_END, 2.0), 2.0)
    ; Part 3 - Bounce 2
    DEF BOUNCE_2_END EQU TOTAL
    DEF BOUNCE_2_PEAK EQU BOUNCE_1_END + DIV(BOUNCE_2_END - BOUNCE_1_END, 2.0)
    DEF BOUNCE_2_PEAK_FRACTION EQU DIV(BOUNCE_2_PEAK, TOTAL)
    DEF BOUNCE_2_OFFSET EQU 1.0 - POW(DIV(BOUNCE_2_END - BOUNCE_1_END, 2.0), 2.0)
    
    FOR TIME, 1, TITLE_SCROLL_DURATION + 1
        DEF TIME_FRACTION = DIV(TIME << 16, TITLE_SCROLL_DURATION << 16)
        IF TIME_FRACTION < FALL_END_FRACTION
            REDEF TIME_FRACTION = DIV(TIME_FRACTION, FALL_END)
            DEF OFFSET = 0
        ELIF TIME_FRACTION < BOUNCE_1_END_FRACTION
            REDEF TIME_FRACTION = TIME_FRACTION - BOUNCE_1_PEAK_FRACTION
            DEF OFFSET = BOUNCE_1_OFFSET
        ELSE
            REDEF TIME_FRACTION = TIME_FRACTION - BOUNCE_2_PEAK_FRACTION
            DEF OFFSET = BOUNCE_2_OFFSET
        ENDC
        DEF VALUE = (MUL(CHANGE, MUL(TOTAL_SQUARED, POW(TIME_FRACTION, 2.0)) + OFFSET) + START) >> 16
        ; Since the start and end positions are set before and after the
        ; scroll anyway, it's not necessary to include them in this
        ; table.
        IF VALUE != TITLE_SCROLL_START_POS && VALUE != TITLE_SCROLL_END_POS
            DB VALUE
        ENDC
    ENDR
    DB TITLE_SCROLL_END_POS

SECTION "Title Screen Window Scroll Position Table", ROM0

DEF WINDOW_CHANGE EQU (TITLE_WINDOW_SCROLL_END_POS - TITLE_WINDOW_SCROLL_START_POS) << 16
DEF WINDOW_START EQU TITLE_WINDOW_SCROLL_START_POS << 16

; Quartic ease-out
; Formula from <https://gizma.com/easing>
TitleWindowScrollPosTable::
    FOR TIME, 1, TITLE_WINDOW_SCROLL_DURATION + 1
        DEF TIME_FRACTION = DIV(TIME << 16, TITLE_SCROLL_DURATION << 16) - 1.0
        DEF VALUE = (MUL(-WINDOW_CHANGE, POW(TIME_FRACTION, 4.0) - 1.0) + WINDOW_START) >> 16
        ; Since the start and end positions are set before and after the
        ; scroll anyway, it's not necessary to include them in this
        ; table.
        IF VALUE != TITLE_WINDOW_SCROLL_START_POS && VALUE != TITLE_WINDOW_SCROLL_END_POS
            DB VALUE
        ENDC
    ENDR
    DB TITLE_WINDOW_SCROLL_END_POS
