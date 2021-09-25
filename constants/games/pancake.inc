INCLUDE "constants/other-hardware.inc"

; Number of frames per tick in the theme
DEF MUSIC_PANCAKE_SPEED EQU 11

; Game palettes
DEF BGP_PANCAKE EQU %11_10_01_00
DEF OBP0_PANCAKE EQU %11_01_00_00   ; Black, Light gray, White
DEF OBP1_PANCAKE EQU %11_10_01_00   ; Black, Dark gray, Light gray

; Position at which the pancakes stay on the frying pan
DEF PANCAKE_X EQU 48
DEF PANCAKE_Y EQU 48

; Initial Y position of pancakes before they fall (X stays the same)
DEF PANCAKE_START_Y EQU -14

DEF PANCAKE_FALL_SPEED EQU 6.0f
; DEF PANCAKE_FALL_SPEED EQU 0
