; Timing constants

; Number of frames the window for a Perfect hit lasts (centred; half
; before and half after the hit)
DEF HIT_PERFECT_WINDOW EQU 7 * 2

; Number of frames the window for an OK hit lasts (centred)
DEF HIT_OK_WINDOW EQU 12 * 2

; Number of frames after a hit to be considered a miss, for use in games
; to react when the player misses a hit
; Not used in the engine since it can be found from
; Total - Perfects - OKs
DEF HIT_MISS_DELAY EQU HIT_OK_WINDOW / 2

; Hit rating type IDs, to be used in hLastHitRating
RSRESET
DEF HIT_BAD RB 1
DEF HIT_OK RB 1
DEF HIT_PERFECT RB 1

; Rating contants

; Percentage score 0-59 -> Bad
; Percentage score 60-79 -> OK
DEF RATING_OK_MIN EQU 6
; Percentage score 80-100 -> Excellent
DEF RATING_EXCELLENT_MIN EQU 8