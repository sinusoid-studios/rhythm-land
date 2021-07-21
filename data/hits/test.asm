INCLUDE "constants/hardware.inc"
INCLUDE "constants/games/test.inc"
INCLUDE "constants/hits.inc"
INCLUDE "macros/hits.inc"

DEF MUSIC_SPEED EQU MUSIC_FILE_SELECT_SPEED

SECTION "Test Game Hit Table", ROMX

xHitTableTest::
    ; Game's hit keys
    DB PADF_A | PADF_B | HITF_RELEASE
    
    hit 8, PADF_A
    hit 8, PADF_A | HITF_RELEASE
    hit 8, PADF_B
    hit 8, PADF_B | HITF_RELEASE
    hit 8, PADF_A
    hit 8, PADF_A | HITF_RELEASE
    hit 8, PADF_B
    hit 8, PADF_B | HITF_RELEASE
    hit 8, PADF_A
    hit 8, PADF_A | HITF_RELEASE
    hit 8, PADF_B
    hit 8, PADF_B | HITF_RELEASE
    hit 8, PADF_A
    hit 8, PADF_A | HITF_RELEASE
    hit 8, PADF_B
    hit 8, PADF_B | HITF_RELEASE
    
    DB HITS_END
