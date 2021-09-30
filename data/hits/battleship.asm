INCLUDE "constants/hardware.inc"
INCLUDE "constants/games/battleship.inc"
INCLUDE "constants/hits.inc"
INCLUDE "macros/hits.inc"

DEF MUSIC_SPEED EQU MUSIC_BATTLESHIP_SPEED

SECTION "Battleship Game Hit Table", ROMX

xHitTableBattleship::
    ; Game's hit keys
    ; Any direction works for the D-Pad side, all combined into Left
    DB PADF_LEFT | PADF_A
    
    ; Section A
    hit 18, PADF_LEFT
    hit 4, PADF_A
    hit 4, PADF_LEFT
    hit 4, PADF_A
    hit 4, PADF_LEFT
    hit 4, PADF_LEFT
    hit 4, PADF_A
    hit 4, PADF_A
    
    hit 4, PADF_LEFT
    hit 4, PADF_A
    hit 4, PADF_A
    hit 4, PADF_LEFT
    hit 4, PADF_LEFT
    hit 4, PADF_A
    hit 4, PADF_LEFT | PADF_A
    hit 4, PADF_LEFT | PADF_A
    
    hit 4, PADF_LEFT
    hit 4, PADF_A
    hit 4, PADF_LEFT
    hit 4, PADF_A
    hit 4, PADF_LEFT
    hit 4, PADF_LEFT
    hit 4, PADF_A
    hit 4, PADF_A
    
    hit 4, PADF_LEFT
    hit 4, PADF_A
    hit 4, PADF_A
    hit 4, PADF_LEFT
    hit 4, PADF_LEFT
    hit 4, PADF_A
    hit 4, PADF_LEFT | PADF_A
    hit 4, PADF_LEFT | PADF_A
    
    ; Section B
    REPT 2
    hit 4, PADF_LEFT
    hit 4, PADF_A
    hit 4, PADF_LEFT
    hit 2, PADF_A
    hit 2, PADF_LEFT
    hit 4, PADF_A
    hit 2, PADF_LEFT
    hit 2, PADF_A
    hit 4, PADF_LEFT | PADF_A
    hit 4, PADF_LEFT | PADF_A
    
    hit 4, PADF_LEFT
    hit 4, PADF_LEFT
    hit 4, PADF_A
    hit 4, PADF_A
    hit 4, PADF_LEFT | PADF_A
    hit 4, PADF_LEFT | PADF_A
    hit 4, PADF_LEFT
    hit 2, PADF_A
    hit 2, PADF_LEFT | PADF_A
    ENDR
    
    ; Section C
    hit 18, PADF_LEFT | PADF_A
    hit 4, PADF_LEFT | PADF_A
    hit 4, PADF_LEFT
    hit 2, PADF_A
    hit 2, PADF_LEFT
    hit 4, PADF_LEFT | PADF_A
    hit 4, PADF_LEFT | PADF_A
    hit 4, PADF_A
    hit 2, PADF_LEFT
    hit 2, PADF_A
    hit 4, PADF_LEFT
    hit 2, PADF_A
    hit 2, PADF_LEFT
    hit 2, PADF_A
    hit 2, PADF_LEFT
    hit 2, PADF_A
    hit 2, PADF_LEFT
    
    hit 4, PADF_A
    hit 2, PADF_LEFT
    hit 2, PADF_A
    hit 4, PADF_LEFT
    hit 2, PADF_A
    hit 2, PADF_LEFT
    
    hit 4, PADF_LEFT | PADF_A
    hit 4, PADF_LEFT | PADF_A
    hit 4, PADF_LEFT
    hit 2, PADF_A
    hit 2, PADF_LEFT
    hit 4, PADF_LEFT | PADF_A
    hit 4, PADF_LEFT | PADF_A
    hit 4, PADF_A
    hit 2, PADF_LEFT
    hit 2, PADF_A
    hit 4, PADF_LEFT
    hit 2, PADF_A
    hit 2, PADF_LEFT
    hit 2, PADF_A
    hit 2, PADF_LEFT
    hit 2, PADF_A
    hit 2, PADF_LEFT
    
    hit 4, PADF_A
    hit 2, PADF_LEFT
    hit 2, PADF_A
    hit 4, PADF_LEFT
    hit 2, PADF_A
    hit 2, PADF_LEFT
    
    ; End
    hit 4, PADF_LEFT
    hit 3, PADF_A
    hit 3, PADF_LEFT | PADF_A
    
    DB HITS_END
