; Number of frames the title scroll lasts (1 beat, but the tempo is
; increasing at the beginning)
DEF TITLE_SCROLL_DURATION EQU 10 + 10 + 10 + 9

; SCY value at the beginning and end of the scroll
DEF TITLE_SCROLL_START_POS EQU LOW(-SCRN_Y)
DEF TITLE_SCROLL_END_POS EQU 0

; Number of frames a flash lasts
DEF TITLE_FLASH_DURATION EQU 5

; Initial star positions
DEF LARGE_STAR_1_X EQU 30 - 3
DEF LARGE_STAR_1_Y EQU 5 - 7
DEF LARGE_STAR_2_X EQU 114 - 1
DEF LARGE_STAR_2_Y EQU 12 - 12
DEF LARGE_STAR_3_X EQU 9 - 1
DEF LARGE_STAR_3_Y EQU 109 - 5
DEF LARGE_STAR_4_X EQU 133 - 4
DEF LARGE_STAR_4_Y EQU 108 - 4
