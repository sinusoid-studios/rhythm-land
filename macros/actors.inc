; Save the scope name of the actor's animation table
MACRO animation_def
    REDEF ANIMATION_TABLE EQUS "\1Animation"
    REDEF METASPRITE_TABLE EQUS "\1Metasprites"
    REDEF TILE_TABLE EQUS "\1Tiles"
    IF _NARG > 1
        REDEF ANIMATION_NAME EQUS "\2"
    ENDC
ENDM

; Define an animation cel
MACRO cel
    DB METASPRITE_\1, \2
ENDM

; Assign an animation cel's number to a constant and export it
MACRO cel_def
    DEF CEL_{ANIMATION_NAME}_\2 EQU ((\1) - {ANIMATION_TABLE}) / 2
    EXPORT CEL_{ANIMATION_NAME}_\2
ENDM

; Jump to an animation cel
MACRO goto_cel
    DB ANIMATION_GOTO, ((\1) - {ANIMATION_TABLE}) / 2
ENDM

; End an animation override
MACRO override_end
    DB ANIMATION_OVERRIDE_END
    IF _NARG > 0
        DB ((\1) - {ANIMATION_TABLE}) / 2
    ELSE
        DB ANIMATION_OVERRIDE_END_NO_TILES
    ENDC
ENDM

; Copy tiles to VRAM
MACRO set_tiles
    DB ANIMATION_SET_TILES
    DW {TILE_TABLE}.\1
    DB (\2) * 16 / 2
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
