INCLUDE "macros/misc.inc"

SECTION "Screen Table", ROM0

ScreenTable::
    full_pointer xGameSkaterDude
    full_pointer xGamePancake
    full_pointer xGameBattleship
    full_pointer xGameSeagullSerenade
    full_pointer Null
    full_pointer ScreenMuseum
    full_pointer ScreenTitle
    full_pointer ScreenGameSelect
    full_pointer ScreenRating
.end::

SECTION "Screen Setup Routine Table", ROM0

ScreenSetupTable::
    full_pointer xGameSetupSkaterDude
    full_pointer xGameSetupPancake
    full_pointer xGameSetupBattleship
    full_pointer xGameSetupSeagullSerenade
    full_pointer Null
    full_pointer ScreenSetupMuseum
    full_pointer ScreenSetupTitle
    full_pointer ScreenSetupGameSelect
    full_pointer ScreenSetupRating
.end::

SECTION "Extra LYC Interrupt Handler Table", ROM0, ALIGN[8]

LYCHandlerTable::
    DW LYCHandlerSkaterDude
    DS 2
    DS 2
    DS 2
    DS 2
    DS 2
    DS 2
    DW LYCHandlerGameSelect
.end::
