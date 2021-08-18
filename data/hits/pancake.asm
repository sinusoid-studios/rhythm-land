INCLUDE "constants/hardware.inc"
INCLUDE "constants/games/pancake.inc"
INCLUDE "constants/hits.inc"
INCLUDE "macros/hits.inc"

SECTION "Pancake Game Hit Table", ROMX

xHitTablePancake::
    ; Game's hit keys
    DB PADF_A
    
    ; TODO
    
    DB HITS_END
