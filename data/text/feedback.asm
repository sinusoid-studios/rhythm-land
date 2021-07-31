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
