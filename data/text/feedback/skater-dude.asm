INCLUDE "constants/charmap.inc"
INCLUDE "macros/feedback.inc"

SECTION "Skater Dude Game Bad Rating Text", ROMX

xTextBadSkaterDude::
    feedback "Sheesh, that kid really shouldn't put himself in such danger."
    feedback_last "Ridiculously irresponsible."

SECTION "Skater Dude Game OK Rating Text", ROMX

xTextOKSkaterDude::
    feedback "Hmm."
    feedback "That looked really dangerous, but he had some cool tricks there."
    feedback_last "It was.<DELAY>",6,".<DELAY>",6,"."
    ; "OK" appears next, in the rating graphic

SECTION "Skater Dude Game Great Rating Text", ROMX

xTextGreatSkaterDude::
    feedback "Huh, that dude knows his stuff!"
    feedback_last "Those tricks were really cool!"

SECTION "Skater Dude Game Perfect Rating Text", ROMX

xTextPerfectSkaterDude::
    feedback "Woah, that dude was super cool!"
    feedback "Unfazed by the heavy traffic!"
    feedback_last "Those were some crazy gnarly tricks!"
