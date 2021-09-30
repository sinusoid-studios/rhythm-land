INCLUDE "constants/charmap.inc"
INCLUDE "macros/misc.inc"

SECTION "Game Description Text Table", ROM0

DescTextTable::
    full_pointer xTextDescSkaterDude
    full_pointer xTextDescPancake
    full_pointer xTextDescBattleship
    full_pointer xTextDescSeagullSerenade
    full_pointer xTextDescNothing
    full_pointer xTextDescJukebox
.end::

SECTION "Skater Dude Game Description", ROMX

xTextDescSkaterDude:
    DB "Skater Dude\n"
    DB "\n"
    DB "Show off gnarly skateboard tricks on the road by jumping in time.<END>"

SECTION "Pancake Game Description", ROMX

xTextDescPancake:
    DB "Pancake\n"
    DB "\n"
    DB "Flip pancakes when they're just right. Watch out: the small ones cook fast!<END>"

SECTION "Battleship Game Description", ROMX

xTextDescBattleship:
    DB "Battleship\n"
    DB "\n"
    DB "Fire away at incoming enemy speedboats! Don't let them get away!<END>"

SECTION "Seagull Serenade Game Description", ROMX

xTextDescSeagullSerenade:
    DB "Seagull Serenade\n"
    DB "\n"
    DB "Squawk to the music while staying in tune with your seagull trio!<END>"

SECTION "Nothing Description", ROMX

xTextDescNothing:
    DB "Sorry! :(\n"
    DB "\n"
    DB "There wasn't enough time to finish this game before the compo deadline.<END>"

SECTION "Jukebox Description", ROMX

xTextDescJukebox:
    DB "Jukebox\n"
    DB "\n"
    DB "Listen to the tunes used in this game!<END>"
