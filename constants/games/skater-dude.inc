; Y speed value set when Skater Dude jumps
DEF SKATER_DUDE_JUMP_HEIGHT EQU 32
; Y position of the ground, to figure out where to stop Skater Dude from
; falling
DEF SKATER_DUDE_GROUND_Y EQU SCRN_Y * 2/3
; X position of Skater Dude (stays constant the entire game)
DEF SKATER_DUDE_X EQU SCRN_X * 5/6

; Animation constants
DEF CEL_SKATER_DUDE_JUMPING EQU 3
DEF CEL_SKATER_DUDE_FALLING EQU 10

; Background map constants
DEF MAP_SKATER_DUDE_WIDTH EQU 132
DEF MAP_SKATER_DUDE_HEIGHT EQU 18

DEF MAP_SKATER_DUDE_START_X EQU (MAP_SKATER_DUDE_WIDTH - SCRN_X_B) * 8
DEF MAP_SKATER_DUDE_START_Y EQU 0
