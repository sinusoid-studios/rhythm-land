INCLUDE "macros/misc.inc"

SECTION "Screen Table", ROM0

ScreenTable::
    full_pointer ScreenTitle
    full_pointer ScreenGameSelect
    full_pointer ScreenMuseum
    full_pointer ScreenRating
    full_pointer xGameSkaterDude
    full_pointer xGameSeagullSerenade
    full_pointer xGameBartender
.end::

SECTION "Screen Setup Routine Table", ROM0

ScreenSetupTable::
    full_pointer ScreenSetupTitle
    full_pointer ScreenSetupGameSelect
    full_pointer ScreenSetupMuseum
    full_pointer ScreenSetupRating
    full_pointer xGameSetupSkaterDude
    full_pointer xGameSetupSeagullSerenade
    full_pointer xGameSetupBartender
.end::
