INCLUDE "defines.inc"

DEF MUSIC_SPEED EQU MUSIC_FILE_SELECT_SPEED

SECTION "Test Game Hit Table", ROMX

xHitTableTest::
    hit 8, PADF_A
    hit 8, PADF_B
    hit 8, PADF_A
    hit 8, PADF_B
    hit 8, PADF_A
    hit 8, PADF_B
    hit 8, PADF_A
    hit 8, PADF_B
    hit 8, PADF_A
    hit 8, PADF_B
    hit 8, PADF_A
    hit 8, PADF_B
    hit 8, PADF_A
    hit 8, PADF_B
    hit 8, PADF_A
    hit 8, PADF_B
    hits_end
