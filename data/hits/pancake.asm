INCLUDE "constants/hardware.inc"
INCLUDE "constants/games/pancake.inc"
INCLUDE "constants/hits.inc"
INCLUDE "macros/hits.inc"

DEF MUSIC_SPEED EQU MUSIC_PANCAKE_SPEED

SECTION "Pancake Game Hit Table", ROMX

xHitTablePancake::
    ; Game's hit keys
    DB PADF_A
    
    REPT 2
    hit 24, PADF_A
    hit 8, PADF_A
    
    hit 24, PADF_A
    hit 8, PADF_A
    ENDR
    
    REPT 2
    hit 20, PADF_A
    hit 4, PADF_A
    
    hit 12, PADF_A
    hit 4, PADF_A
    
    hit 16, PADF_A
    hit 8, PADF_A
    ENDR
    
    REPT 2
    hit 20, PADF_A
    hit 4, PADF_A
    
    hit 12, PADF_A
    hit 4, PADF_A
    
    hit 4, PADF_A
    hit 4, PADF_A
    
    hit 8, PADF_A
    hit 8, PADF_A
    ENDR
    
    DB HITS_END
