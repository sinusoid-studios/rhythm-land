DEF FIRST_CUE = 1

; An entry to a game's cue table, in ticks using a defined music speed
MACRO cue
    fcue \1 * MUSIC_SPEED, \2
ENDM

; An entry to a game's cue table, in frames
MACRO fcue
    DEF FRAMES = \1
    IF FIRST_CUE == 1
        ; 1-frame delay between a PLAYINST command and an instrument update
        REDEF FRAMES = FRAMES + 1
    ENDC
    ASSERT LOW(FRAMES) != LOW(CUES_END), STRFMT("%d is reserved for the end of the cue table", CUES_END)
    DB FRAMES, \2
    REDEF FIRST_CUE = 0
ENDM

; Signal the end of a cue table
MACRO cues_end
    DB CUES_END
ENDM
