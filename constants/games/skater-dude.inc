; Number of frames per tick in the theme
DEF MUSIC_SKATER_DUDE_SPEED EQU 8

; Music sync data values
DEF SYNC_SKATER_DUDE_END EQU 1

; Y position of Skater Dude normally
DEF SKATER_DUDE_Y EQU SCRN_Y * 1/2 + 5
; X position of Skater Dude (stays constant the entire game)
DEF SKATER_DUDE_X EQU SCRN_X * 2/3
; Skater Dude starts off-screen and skates on, skates off-screen at the
; end
DEF SKATER_DUDE_START_X EQU SCRN_X
DEF SKATER_DUDE_END_X EQU -24
; Number of pixels Skater Dude moves vertically when jumping
DEF SKATER_DUDE_JUMP_HEIGHT EQU 32
; X speed of Skater Dude when skating on or off the screen
DEF SKATER_DUDE_IN_SPEED EQU -DIV(1.0, 3.0) >> (16 - 3)
DEF SKATER_DUDE_OUT_SPEED EQU -1.5 >> (16 - 3)

; Skater Dude states, used at the beginning and end of the game
RSRESET
DEF SKATER_DUDE_STATE_IN RB 1
DEF SKATER_DUDE_STATE_OUT RB 1
DEF SKATER_DUDE_STATE_END RB 1
DEF NUM_SKATER_DUDE_STATES EQU _RS

; Position of the Danger Alert
DEF DANGER_ALERT_X EQU 8 * 1
DEF DANGER_ALERT_Y EQU 12 * 8 - 2

DEF SKATER_DUDE_SLO_MO_DURATION EQU MUSIC_SKATER_DUDE_SPEED * 4
DEF SKATER_DUDE_SLO_MO_DIVIDE EQU 4
DEF SKATER_DUDE_SLO_MO_UPDATE_MASK EQU 3

DEF OBSTACLE_SPEED EQU 12 << 3
DEF OBSTACLE_X EQU -32
DEF OBSTACLE_Y EQU 12 * 7

; Background map constants
DEF MAP_SKATER_DUDE_WIDTH EQU 132
DEF MAP_SKATER_DUDE_HEIGHT EQU 18

DEF MAP_SKATER_DUDE_START_X EQU (MAP_SKATER_DUDE_WIDTH - SCRN_X_B) * 8
DEF MAP_SKATER_DUDE_START_Y EQU 0
