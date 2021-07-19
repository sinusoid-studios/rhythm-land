; Number of frames the title scroll lasts (1 beat, but the tempo is
; increasing at the beginning)
DEF TITLE_SCROLL_DURATION EQU 10 + 10 + 10 + 9

; SCY value at the beginning and end of the scroll
DEF TITLE_SCROLL_START_POS EQU LOW(-SCRN_Y)
DEF TITLE_SCROLL_END_POS EQU 0

; Number of frames a flash lasts
DEF TITLE_FLASH_DURATION EQU 5