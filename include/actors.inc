; Save the scope name of the actor's animation table
MACRO animation_def
    REDEF ANIMATION_TABLE EQUS "\1Animation"
    REDEF METASPRITE_TABLE EQUS "\1Metasprites"
    IF _NARG == 2
        REDEF ANIMATION_NAME EQUS "\2"
    ENDC
ENDM

; Define an animation cel
MACRO cel
    DB METASPRITE_\1, \2
ENDM

; Name an animation cel
MACRO cel_def
    DEF CEL_{ANIMATION_NAME}_\1 EQU (@ - {ANIMATION_TABLE}) / 2
    EXPORT CEL_{ANIMATION_NAME}_\1
ENDM

; Jump to an animation cel
MACRO goto_cel
    DB ANIMATION_GOTO, ((\1) - {ANIMATION_TABLE}) / 2
ENDM

; Meta-sprites

; Define a meta-sprite
MACRO metasprite
    ; Remove period in meta-sprite name
    REDEF NAME EQUS STRSUB("\1", 2)
    ; Assign meta-sprite ID to name
    DEF METASPRITE_{NAME} EQU (@ - {METASPRITE_TABLE}) / 2
    
    ; Pointer to meta-sprite definition
    DW \1
ENDM
