SECTION "Song Data Table", ROM0, ALIGN[8]
SongDataTable:
    DW FileSelectData
    DW SkaterDudeData

DEF NUM_SONGS EQU (@ - SongDataTable) / 2

FileSelectData:
    DB BANK(Inst_FileSelect)
    DW Inst_FileSelect
    DB BANK(Music_FileSelect)
    DW Music_FileSelect
SkaterDudeData:
    DB BANK(Inst_SkaterDude)
    DW Inst_SkaterDude
    DB BANK(Music_SkaterDude)
    DW Music_SkaterDude

SECTION "Song Title Table", ROM0, ALIGN[8]
SongTitleTable:
    DW FileSelectString
    DW SkaterDudeString

FileSelectString:
    DB "    File Select     ",0
SkaterDudeString:
    DB "    Skater Dude     ",0

; Get NUM_SFX
INCLUDE "constants/sfx.inc"
