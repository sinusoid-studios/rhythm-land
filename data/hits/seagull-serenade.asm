INCLUDE "constants/hardware.inc"
INCLUDE "constants/games/seagull-serenade.inc"
INCLUDE "constants/hits.inc"
INCLUDE "macros/hits.inc"

DEF MUSIC_SPEED EQU MUSIC_SEAGULL_SERENADE_SPEED

SECTION "Seagull Serenade Game Hit Table", ROMX

xHitTableSeagullSerenade::
    ; Game's hit keys
    ; Left and Right combined into Left since either is fine (don't
    ; require pressing both Left and Right at the same time)
    DB PADF_UP | PADF_LEFT | PADF_DOWN
    
    hit 64 + 12, PADF_UP
    hit 16, PADF_UP
    hit 16, PADF_UP
    hit 10, PADF_UP
    hit 8, PADF_LEFT
    
    hit 14, PADF_UP
    hit 16, PADF_UP
    hit 16, PADF_UP
    hit 10, PADF_UP
    hit 8, PADF_LEFT
    
    hit 8, PADF_DOWN
    hit 8, PADF_DOWN
    hit 14, PADF_UP
    hit 10, PADF_DOWN
    hit 8, PADF_DOWN
    hit 14, PADF_UP
    
    hit 16, PADF_UP
    hit 16, PADF_UP
    hit 16, PADF_UP
    hit 10, PADF_UP
    hit 8, PADF_LEFT
    
    hit 14, PADF_UP
    hit 16, PADF_DOWN
    hit 12, PADF_UP
    hit 8, PADF_DOWN
    hit 6, PADF_UP
    hit 8, PADF_LEFT
    
    DB HITS_END
