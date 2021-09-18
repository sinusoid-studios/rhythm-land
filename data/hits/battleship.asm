INCLUDE "constants/hardware.inc"
INCLUDE "constants/games/battleship.inc"
INCLUDE "constants/hits.inc"
INCLUDE "macros/hits.inc"

SECTION "Battleship Game Hit Table", ROMX

xHitTableBattleship::
    ; Game's hit keys
    DB PADF_UP | PADF_LEFT | PADF_RIGHT
    
    ; TODO
    
    DB HITS_END
