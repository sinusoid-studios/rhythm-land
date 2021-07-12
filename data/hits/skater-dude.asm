INCLUDE "defines.inc"
INCLUDE "hits.inc"

DEF MUSIC_SPEED EQU MUSIC_SKATER_DUDE_SPEED

SECTION "Skater Dude Game Hit Table", ROMX

xHitTableSkaterDude::
    ; Section A
    hit 64 + 4, PADF_A
    hit 32, PADF_A
    hit 32, PADF_A
    hit 32, PADF_A
    
    ; Section B
    hit 32, PADF_A
    hit 32 - 8, PADF_A
    
    hit 8, PADF_A
    hit 32 - 8, PADF_A
    
    hit 8, PADF_A
    hit 32 - 8, PADF_A
    
    hit 8, PADF_A
    
    ; Section C
    hit 32, PADF_A
    hit 8, PADF_A
    hit 8, PADF_A
    
    REPT 3
    hit 32 - 8 * 2, PADF_A
    hit 8, PADF_A
    hit 8, PADF_A
    ENDR
    
    hits_end
