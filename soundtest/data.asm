SECTION "Song Data Table", ROM0, ALIGN[8]

SongDataTable:
    DW TitleData
    DW GameSelectData
    DW BadData
    DW OKData
    DW GreatData
    DW SkaterDudeData
    DW SeagullSerenadeData
    DW PancakeData
    DW BattleshipData

DEF NUM_SONGS EQU (@ - SongDataTable) / 2

TitleData:
    DB BANK(Inst_Title)
    DW Inst_Title
    DB BANK(Music_Title)
    DW Music_Title
GameSelectData:
    DB BANK(Inst_GameSelect)
    DW Inst_GameSelect
    DB BANK(Music_GameSelect)
    DW Music_GameSelect
BadData:
    DB BANK(Inst_Bad)
    DW Inst_Bad
    DB BANK(Music_Bad)
    DW Music_Bad
OKData:
    DB BANK(Inst_OK)
    DW Inst_OK
    DB BANK(Music_OK)
    DW Music_OK
GreatData:
    DB BANK(Inst_Great)
    DW Inst_Great
    DB BANK(Music_Great)
    DW Music_Great
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
PancakeData:
    DB BANK(Inst_Pancake)
    DW Inst_Pancake
    DB BANK(Music_Pancake)
    DW Music_Pancake
BattleshipData:
    DB BANK(Inst_Battleship)
    DW Inst_Battleship
    DB BANK(Music_Battleship)
    DW Music_Battleship

SECTION "Song Title Table", ROM0, ALIGN[8]

SongTitleTable:
    DW TitleString
    DW GameSelectString
    DW BadString
    DW OKString
    DW GreatString
    DW SkaterDudeString
    DW SeagullSerenadeString
    DW PancakeString
    DW BattleshipString

TitleString:
    DB "       Title        ",0
GameSelectString:
    DB "    Game Select     ",0
BadString:
    DB "        Bad         ",0
OKString:
    DB "         OK         ",0
GreatString:
    DB "       Great        ",0
SkaterDudeString:
    DB "    Skater Dude     ",0
SeagullSerenadeString:
    DB "  Seagull Serenade  ",0
PancakeString:
    DB "      Pancake       ",0
BattleshipString:
    DB "     Battleship     ",0

; Get NUM_SFX
INCLUDE "constants/sfx.inc"
