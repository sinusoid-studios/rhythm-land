; Number of spots to put in the actor tables
DEF MAX_NUM_ACTORS EQU 8

; Actor types
RSRESET
DEF ACTOR_SKATER_DUDE RB 1
DEF NUM_ACTORS EQU _RS

DEF ACTOR_EMPTY EQU -1

; Animation special values
DEF ANIMATION_GOTO EQU -1
DEF ANIMATION_KILL_ACTOR EQU -2

; Meta-sprite special values
DEF METASPRITE_END EQU -128
