; Number of frames the transition lasts (one direction)
DEF TRANSITION_DURATION EQU 60
; Number of frames to delay while the screen is covered
DEF TRANSITION_DELAY EQU 30

; WX value at the beginning and end of the transition
DEF TRANSITION_START_POS EQU SCRN_X + 7
DEF TRANSITION_END_POS EQU 0 + 7

; Number of frames difference (delay) between each block
DEF TRANSITION_BLOCK_DIFFERENCE EQU 2

; Number of frames between each master volume decrease step
DEF TRANSITION_MUSIC_FADE_SPEED EQU (TRANSITION_DURATION * 3/2) / 8

; Values used in hTransitionState
RSRESET
DEF TRANSITION_STATE_OFF RB 1
DEF TRANSITION_STATE_IN RB 1
DEF TRANSITION_STATE_OUT RB 1
