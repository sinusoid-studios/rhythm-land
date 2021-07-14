; Y position of Skater Dude normally
DEF SKATER_DUDE_Y EQU SCRN_Y * 1/2 + 5
; X position of Skater Dude (stays constant the entire game)
DEF SKATER_DUDE_X EQU SCRN_X * 5/6 - 8
; Number of pixels Skater Dude moves vertically when jumping
DEF SKATER_DUDE_JUMP_HEIGHT EQU 32

; Animation constants
DEF CEL_SKATER_DUDE_JUMPING EQU 5
DEF CEL_SKATER_DUDE_FALLING EQU 13

; Background map constants
DEF MAP_SKATER_DUDE_WIDTH EQU 132
DEF MAP_SKATER_DUDE_HEIGHT EQU 18

DEF MAP_SKATER_DUDE_START_X EQU (MAP_SKATER_DUDE_WIDTH - SCRN_X_B) * 8
DEF MAP_SKATER_DUDE_START_Y EQU 0
