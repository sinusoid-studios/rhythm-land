INCLUDE "macros/misc.inc"

SECTION "Game Table", ROM0

GameTable::
    full_pointer TitleScreen
    full_pointer GameSelectScreen
    full_pointer Museum
    full_pointer RatingScreen
    full_pointer xGameTest
    full_pointer xGameSkaterDude
    full_pointer xGameSeagullSerenade
    full_pointer xGameBartender
.end::

SECTION "Game Setup Routine Table", ROM0

GameSetupTable::
    full_pointer SetupTitleScreen
    full_pointer SetupGameSelectScreen
    full_pointer SetupMuseum
    full_pointer SetupRatingScreen
    full_pointer xGameSetupTest
    full_pointer xGameSetupSkaterDude
    full_pointer xGameSetupSeagullSerenade
    full_pointer xGameSetupBartender
.end::
