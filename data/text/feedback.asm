INCLUDE "constants/charmap.inc"
INCLUDE "macros/feedback.inc"
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
    rating_text Pancake
    rating_text Battleship
    rating_text SeagullSerenade
.end::

; Skater Dude

SECTION "Skater Dude Game Bad Rating Text", ROMX

xTextBadSkaterDude:
    feedback "Sheesh, that kid really shouldn't put himself in such danger."
    feedback_last "Ridiculously irresponsible."

SECTION "Skater Dude Game OK Rating Text", ROMX

xTextOKSkaterDude:
    feedback "Hmm."
    feedback "That looked really dangerous, but he had some cool tricks there."
    feedback_last "It was.<DELAY>",6,".<DELAY>",6,"."
    ; "OK" appears next, in the rating graphic

SECTION "Skater Dude Game Great Rating Text", ROMX

xTextGreatSkaterDude:
    feedback "Huh, that dude knows his stuff!"
    feedback_last "Those tricks were really cool!"

SECTION "Skater Dude Game Perfect Rating Text", ROMX

xTextPerfectSkaterDude:
    feedback "Woah, that dude was super cool!"
    feedback "Unfazed by the heavy traffic!"
    feedback_last "Those were some crazy gnarly tricks!"

; Pancake

SECTION "Pancake Game Bad Rating Text", ROMX

xTextBadPancake:
    feedback "Pftew! That tasted really awful!"
    feedback_last "Don't quit your day job to take up cooking."

SECTION "Pancake Game OK Rating Text", ROMX

xTextOKPancake:
    feedback "Well, it's not terrible..."
    feedback_last "I guess it's edible."

SECTION "Pancake Game Great Rating Text", ROMX

xTextGreatPancake:
    feedback "Reminds me of my mother's cooking."
    feedback_last "These are some pretty tasty pancakes!"

SECTION "Pancake Game Perfect Rating Text", ROMX

xTextPerfectPancake:
    feedback "Deliciously fluffy and cooked to perfection."
    feedback_last "Excellent pancakes, my compliments to the chef!"

; Battleship

SECTION "Battleship Game Bad Rating Text", ROMX

xTextBadBattleship:
    feedback "What a waste of ammunitions."
    feedback_last "I doubt you could hit the broad side of a barn."

SECTION "Battleship Game OK Rating Text", ROMX

xTextOKBattleship:
    feedback "Not exceptional by any means..."
    feedback_last "I've been better shooting, but I've also seen worse."

SECTION "Battleship Game Great Rating Text", ROMX

xTextGreatBattleship:
    feedback "Artillery seems to be a specialty of yours."
    feedback_last "Looks like you have quite the good aim with that thing!"

SECTION "Battleship Game Perfect Rating Text", ROMX

xTextPerfectBattleship:
    feedback "That right there should be the gold standard for naval combat!"
    feedback_last "Such accuracy and speed... it brings a tear to my eye."

; Seagull Serenade

SECTION "Seagull Serenade Game Bad Rating Text", ROMX

xTextBadSeagullSerenade:
    feedback "My ears hurt a bit after that."
    feedback_last "Quite an embarrassing performance."

SECTION "Seagull Serenade Game OK Rating Text", ROMX

xTextOKSeagullSerenade:
    feedback  "There were a few parts I liked."
    feedback  "Lots of room for improvement."
    feedback_last  "Pretty average overall."

SECTION "Seagull Serenade Game Great Rating Text", ROMX

xTextGreatSeagullSerenade:
    feedback "How melodious!"
    feedback "And all while staying in tune, that takes skill."
    feedback_last "I'm impressed with that performance!"

SECTION "Seagull Serenade Game Perfect Rating Text", ROMX

xTextPerfectSeagullSerenade:
    feedback "Outstanding!"
    feedback "That may be one of the best songs I've ever heard!"
    feedback_last "A fantastic showing. Encore!"
