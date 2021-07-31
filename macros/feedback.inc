; One "line" of feedback, separated from the next with a blank line and
; a bit of delay.
MACRO feedback
    DB \1, "\n\n"
    DB TEXT_DELAY, 40
ENDM

; The last "line" of feedback, which isn't followed by any more text and
; thus doesn't need the newlines. Also includes the text terminator
; value.
MACRO feedback_last
    DB \1
    DB TEXT_END
ENDM
