DEF FIRST_HIT = 1

; An entry to a game's hit table, in ticks using a defined music speed
MACRO hit
    fhit (\1) * MUSIC_SPEED, \2
ENDM

; An entry to a game's hit table, in frames
MACRO fhit
    DEF FRAMES = \1
    IF FIRST_HIT == 1
        ; 1-frame delay between a PLAYINST command and an instrument update
        REDEF FRAMES = FRAMES + 1
    ENDC
    REDEF FIRST_HIT = 0
    
    IF LOW(FRAMES) != 0
        REDEF FRAMES = FRAMES + (1 << 8)
    ENDC
    
    ASSERT LOW(FRAMES) != LOW(HITS_END), STRFMT("%d is reserved for the end of the hit table", HITS_END)
    DW FRAMES
    DB \2
ENDM
