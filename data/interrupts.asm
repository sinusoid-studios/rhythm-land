INCLUDE "constants/hardware.inc"
INCLUDE "constants/interrupts.inc"
INCLUDE "constants/games/skater-dude.inc"

SECTION "LYC Value Table", ROM0, ALIGN[8]

LYCTable::
.skaterDude::
    FOR SCANLINE, 0, BUILDING_BOTTOM, 2
        IF SCANLINE - 1 >= 0 && SCANLINE + 1 < MAP_SKATER_DUDE_SIDEWALK_Y * 8 - 1
            DB SCANLINE - 1
        ENDC
    ENDR
    DB MAP_SKATER_DUDE_SIDEWALK_Y * 8 - 1
    DB MAP_SKATER_DUDE_ROAD_Y * 8 - 1
    DB MAP_SKATER_DUDE_GRASS_Y * 8 - 1
    DB LYC_FRAME_END
.end::
