SECTION "Song Data Table", ROM0, ALIGN[8]
SongDataTable:
    DW TitleData
    DW FileSelectData
    DW OKData
    DW SkaterDudeData
    DW SeagullSerenadeData
    DW BattleshipData

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
OKData:
    DB BANK(Inst_OK)
    DW Inst_OK
    DB BANK(Music_OK)
    DW Music_OK
SkaterDudeData:
    DB BANK(Inst_SkaterDude)
    DW Inst_SkaterDude
    DB BANK(Music_SkaterDude)
    DW Music_SkaterDude
SeagullSerenadeData:
    DB BANK(Inst_SeagullSerenade)
    DW Inst_SeagullSerenade
    DB BANK(Music_SeagullSerenade)
    DW Music_SeagullSerenade
BattleshipData:
    DB BANK(Inst_Battleship)
    DW Inst_Battleship
    DB BANK(Music_Battleship)
    DW Music_Battleship

SECTION "Song Title Table", ROM0, ALIGN[8]
SongTitleTable:
    DW TitleString
    DW FileSelectString
    DW OKString
    DW SkaterDudeString
    DW SeagullSerenadeString
    DW BattleshipString

TitleString:
    DB "       Title        ",0
FileSelectString:
    DB "    File Select     ",0
OKString:
    DB "         OK         ",0
SkaterDudeString:
    DB "    Skater Dude     ",0
SeagullSerenadeString:
    DB "  Seagull Serenade  ",0
BattleshipString:
    DB "     Battleship     ",0

; Get NUM_SFX
INCLUDE "constants/sfx.inc"
