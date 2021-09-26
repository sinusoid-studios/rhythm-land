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
    
    DB HITS_END
