; An entry to a game's hit table, in ticks using a defined pattern speed
MACRO hit
    fhit \1 * PATTERN_SPEED
ENDM

; An entry to a game's hit table, in frames
MACRO fhit
    ASSERT LOW(\1) != LOW(HITS_END), STRFMT("%d is reserved for the end of the hit table", HITS_END)
    DB \1
ENDM

; Signal the end of a hit table
MACRO hits_end
    DB HITS_END
ENDM
