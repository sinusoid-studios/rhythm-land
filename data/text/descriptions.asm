INCLUDE "constants/charmap.inc"
INCLUDE "macros/misc.inc"

SECTION "Game Description Text Table", ROM0

DescTextTable::
    full_pointer xTextDescSkaterDude
    full_pointer xTextDescSeagullSerenade
    full_pointer xTextDescBartender
    full_pointer xTextDescPancake
    full_pointer xTextDescBattleship
.end::

SECTION "Skater Dude Game Description", ROMX

xTextDescSkaterDude:
    DB "Skater Dude\n"
    DB "\n"
    DB "Show off gnarly skateboard tricks on the road by jumping in time.<END>"

SECTION "Seagull Serenade Game Description", ROMX

xTextDescSeagullSerenade:
    DB "Seagull Serenade\n"
    DB "\n"
    DB "Squawk to the music while staying in tune in your seagull trio!<END>"

SECTION "Bartender Game Description", ROMX

xTextDescBartender:
    DB "Bartender\n"
    DB "\n"
    DB "unfinished<END>"

SECTION "Pancake Game Description", ROMX

xTextDescPancake:
    DB "Pancake\n"
    DB "\n"
    DB "unfinished<END>"

SECTION "Battleship Game Description", ROMX

xTextDescBattleship:
    DB "Battleship\n"
    DB "\n"
    DB "unfinished<END>"
