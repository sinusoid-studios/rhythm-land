INCLUDE "constants/charmap.inc"
INCLUDE "macros/misc.inc"

; Simplify making pointers for every type of rating
MACRO rating_text
    full_pointer xTextBad\1
    full_pointer xTextOK\1
    full_pointer xTextGreat\1
    full_pointer xTextPerfect\1
ENDM

SECTION "Overall Rating Text Table", ROM0

RatingTextTable::
    rating_text SkaterDude
    rating_text SeagullSerenade
.end::

SECTION "Skater Dude Game Bad Rating Text", ROMX

xTextBadSkaterDude:
    DB "Sheesh, that kid really shouldn't put himself in such danger.\n\n"
    DB TEXT_DELAY, 40
    DB "Ridiculously irresponsible.<END>"

SECTION "Skater Dude Game OK Rating Text", ROMX

xTextOKSkaterDude:
    DB "Hmm.\n\n"
    DB TEXT_DELAY, 40
    DB "That looked really dangerous, but he had some cool tricks there.\n\n"
    DB TEXT_DELAY, 40
    DB "It was... OK.<END>"

SECTION "Skater Dude Game Great Rating Text", ROMX

xTextGreatSkaterDude:
    DB "Huh, that dude knows his stuff!\n\n"
    DB TEXT_DELAY, 40
    DB "Those tricks were really cool!<END>"

SECTION "Skater Dude Game Perfect Rating Text", ROMX

xTextPerfectSkaterDude:
    DB "Woah, that dude was super cool!\n\n"
    DB TEXT_DELAY, 40
    DB "Unfazed by the heavy traffic!\n\n"
    DB TEXT_DELAY, 40
    DB "Those were some crazy gnarly tricks!<END>"

SECTION "Seagull Serenade Game Bad Rating Text", ROMX

xTextBadSeagullSerenade:
    DB "My ears hurt a bit after that.\n\n"
    DB TEXT_DELAY, 40
    DB "Quite an embarrassing performance.<END>"

SECTION "Seagull Serenade Game OK Rating Text", ROMX

xTextOKSeagullSerenade:
    DB  "There were a few parts I liked.\n\n"
    DB TEXT_DELAY, 40
    DB  "Lots of room for improvement.\n\n"
    DB TEXT_DELAY, 40
    DB  "Pretty average overall.<END>"

SECTION "Seagull Serenade Game Great Rating Text", ROMX

xTextGreatSeagullSerenade:
    DB "How melodious!\n\n"
    DB TEXT_DELAY, 40
    DB "And all while staying in tune, that takes skill.\n\n"
    DB TEXT_DELAY, 40
    DB "I'm impressed with that performance!<END>"

SECTION "Seagull Serenade Game Perfect Rating Text", ROMX

xTextPerfectSeagullSerenade:
    DB "Outstanding!\n\n"
    DB TEXT_DELAY, 40
    DB "That may be one of the best songs I've ever heard!\n\n"
    DB TEXT_DELAY, 40
    DB "A fantastic showing. Encore!<END>"
