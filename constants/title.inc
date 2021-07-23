; Music sync data values
DEF SYNC_TITLE_BEAT EQU 1
DEF SYNC_TITLE_FLASH EQU 2

; Palettes
DEF TITLE_BGP EQU %11_10_01_00
DEF TITLE_OBP0 EQU %10_01_00_00 ; Dark gray, Light gray, White

; Height of "press start" text in tiles
DEF MAP_TITLE_PRESS_START_HEIGHT EQU 2

; Number of frames the title scroll lasts (1 beat, but the tempo is
; increasing at the beginning)
DEF TITLE_SCROLL_DURATION EQU 10 + 10 + 10 + 9

; SCY value at the beginning and end of the scroll
DEF TITLE_SCROLL_START_POS EQU LOW(-SCRN_Y)
DEF TITLE_SCROLL_END_POS EQU 0

; Number of frames the "press start" window scroll lasts (1/2 beat)
DEF TITLE_WINDOW_SCROLL_DURATION EQU 9 + 9

; WY value at the beginning and end of the window scroll
DEF TITLE_WINDOW_SCROLL_START_POS EQU SCRN_Y
DEF TITLE_WINDOW_SCROLL_END_POS EQU 14 * 8

; Number of frames a flash lasts
DEF TITLE_FLASH_DURATION EQU 5
