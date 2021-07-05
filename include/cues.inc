; An entry to a game's cue table, in ticks using a defined pattern speed
MACRO cue
    fcue \1 * PATTERN_SPEED, \2
ENDM

; An entry to a game's cue table, in frames
MACRO fcue
    ASSERT LOW(\1) != LOW(CUES_END), STRFMT("%d is reserved for the end of the cue table", CUES_END)
    DB \1, \2
ENDM

; Signal the end of a cue table
MACRO cues_end
    DB CUES_END
ENDM
