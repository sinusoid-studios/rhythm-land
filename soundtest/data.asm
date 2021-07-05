SECTION "Song Data Table", ROM0, ALIGN[8]
SongDataTable:
    DW FileSelectData

DEF NUM_SONGS EQU (@ - SongDataTable) / 2

FileSelectData:
    DB BANK(Inst_FileSelect)
    DW Inst_FileSelect
    DB BANK(Music_FileSelect)
    DW Music_FileSelect

SECTION "Song Title Table", ROM0, ALIGN[8]
SongTitleTable:
    DW FileSelectString

FileSelectString:
    DB "    File Select     ",0

; Get NUM_SFX
INCLUDE "constants/sfx.inc"
