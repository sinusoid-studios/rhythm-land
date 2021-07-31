INCLUDE "constants/charmap.inc"

SECTION "Seagull Serenade Game Bad Rating Text", ROMX

xTextBadSeagullSerenade::
    DB "My ears hurt a bit after that.\n\n"
    DB TEXT_DELAY, 40
    DB "Quite an embarrassing performance.<END>"

SECTION "Seagull Serenade Game OK Rating Text", ROMX

xTextOKSeagullSerenade::
    DB  "There were a few parts I liked.\n\n"
    DB TEXT_DELAY, 40
    DB  "Lots of room for improvement.\n\n"
    DB TEXT_DELAY, 40
    DB  "Pretty average overall.<END>"

SECTION "Seagull Serenade Game Great Rating Text", ROMX

xTextGreatSeagullSerenade::
    DB "How melodious!\n\n"
    DB TEXT_DELAY, 40
    DB "And all while staying in tune, that takes skill.\n\n"
    DB TEXT_DELAY, 40
    DB "I'm impressed with that performance!<END>"

SECTION "Seagull Serenade Game Perfect Rating Text", ROMX

xTextPerfectSeagullSerenade::
    DB "Outstanding!\n\n"
    DB TEXT_DELAY, 40
    DB "That may be one of the best songs I've ever heard!\n\n"
    DB TEXT_DELAY, 40
    DB "A fantastic showing. Encore!<END>"
