DEF FIRST_HIT = 1
DEF NUM_HITS = 0

; An entry to a game's hit table, in ticks using a defined music speed
MACRO hit
    fhit \1 * MUSIC_SPEED, \2
ENDM

; An entry to a game's hit table, in frames
MACRO fhit
    DEF FRAMES = \1
    IF FIRST_HIT == 1
        ; 1-frame delay between a PLAYINST command and an instrument update
        REDEF FRAMES = FRAMES + 1
    ENDC
    REDEF FIRST_HIT = 0
    
    FOR N, 8
        REDEF NUM_HITS = NUM_HITS + (((\2) >> N) & 1)
    ENDR
    
    ASSERT LOW(FRAMES) != LOW(HITS_END), STRFMT("%d is reserved for the end of the hit table", HITS_END)
    DB FRAMES, \2
ENDM

; Signal the end of a hit table
MACRO hits_end
    DB HITS_END, NUM_HITS
ENDM
