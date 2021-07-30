INCLUDE "constants/charmap.inc"
INCLUDE "macros/misc.inc"

SECTION "Music Name Table", ROM0

MusicNameTable::
    full_pointer xTextMusicTitle
    full_pointer xTextMusicFileSelect
    full_pointer xTextMusicSkaterDude
    full_pointer xTextMusicSeagullSerenade
.end::

SECTION "Title Theme Name", ROMX

xTextMusicTitle:
    DB "Title"
    DB TEXT_END

SECTION "File Select Theme Name", ROMX

xTextMusicFileSelect:
    DB "File Select"
    DB TEXT_END

SECTION "Skater Dude Theme Name", ROMX

xTextMusicSkaterDude:
    DB "Skater Dude"
    DB TEXT_END

SECTION "Seagull Serenade Theme Name", ROMX

xTextMusicSeagullSerenade:
    DB "Seagull Serenade"
    DB TEXT_END
