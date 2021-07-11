SECTION "Song Data Table", ROM0, ALIGN[8]
SongDataTable:
    DW TitleData
    DW FileSelectData
    DW SkaterDudeData

DEF NUM_SONGS EQU (@ - SongDataTable) / 2

TitleData:
    DB BANK(Inst_Title)
    DW Inst_Title
    DB BANK(Music_Title)
    DW Music_Title
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
    DW TitleString
    DW FileSelectString
    DW SkaterDudeString

TitleString:
    DB "       Title        ",0
FileSelectString:
    DB "    File Select     ",0
SkaterDudeString:
    DB "    Skater Dude     ",0

; Get NUM_SFX
INCLUDE "constants/sfx.inc"
