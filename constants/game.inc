; Number of bytes to allocate for the stack
DEF STACK_SIZE EQU 24 * 2

; Number of cycles the OAM DMA routine's waitloop takes each iteration
DEF DMA_LOOP_CYCLES EQU 1 + 3

; Timing constants

; Number of frames the window for a Perfect hit lasts (centred; half
; before and half after the hit)
DEF HIT_PERFECT_WINDOW EQU 7 * 2

; Number of frames the window for an OK hit lasts (centred)
DEF HIT_OK_WINDOW EQU 12 * 2

; Rating contants

; Percentage score 0-59 -> Bad
; Percentage score 60-79 -> OK
DEF RATING_OK_MIN EQU 6
; Percentage score 80-100 -> Excellent
DEF RATING_EXCELLENT_MIN EQU 8

; Misc.

DEF CUES_END EQU -1
