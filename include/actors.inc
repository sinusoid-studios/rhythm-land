; Save the scope name of the actor's animation table
MACRO animation_def
    DEF ANIMATION_TABLE EQUS "\1Animation"
ENDM

; Define an animation cel
MACRO cel
    DB METASPRITE_\1, \2
ENDM

; Jump to an animation cel
MACRO goto_cel
    DB ANIMATION_GOTO, ((\1) - {ANIMATION_TABLE}) / 2
ENDM

; Meta-sprites

DEF CURRENT_METASPRITE = 0

; Define a meta-sprite
MACRO metasprite
    ; Pointer to meta-sprite definition
    DW \1
    
    ; Remove period in meta-sprite name
    REDEF NAME EQUS STRSUB("\1", 2)
    ; Assign meta-sprite ID to name
    DEF METASPRITE_{NAME} EQU CURRENT_METASPRITE
    REDEF CURRENT_METASPRITE = CURRENT_METASPRITE + 1
ENDM
