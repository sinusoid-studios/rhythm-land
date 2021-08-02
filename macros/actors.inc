; Save the scope name of the actor's animation table
MACRO animation
    REDEF ANIMATION_TABLE EQUS "xActor\1Animation"
    REDEF METASPRITE_TABLE EQUS "xActor\1Metasprites"
    REDEF TILE_TABLE EQUS "xActor\1Tiles"
    IF _NARG > 1
        REDEF ACTOR_NAME EQUS "\2"
    ENDC
ENDM

; Define an animation cel
MACRO cel
    DB METASPRITE_\1, \2
ENDM

; Assign an animation cel's number to a constant and export it
MACRO def_cel
    DEF CEL_{ACTOR_NAME}_\2 EQU ((\1) - {ANIMATION_TABLE}) / 2
    EXPORT CEL_{ACTOR_NAME}_\2
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
    IF _NARG > 1
        ; Local part of label and tile count given
        DW {TILE_TABLE}.\1
        DB (\2) * 16 / 2
    ELSE
        ; No local part of label -> use global part only
        DW {TILE_TABLE}
        DB (\1) * 16 / 2
    ENDC
ENDM

; Meta-sprites

; Define an object, for use in meta-sprite "draw lists"
MACRO obj
    ; Apply object position offset so the actor renderer doesn't have to
    DB \1 + 16, \2 + 8, \3, \4
ENDM

; Define a meta-sprite
MACRO metasprite
    ; Remove period in meta-sprite name
    REDEF NAME EQUS STRSUB("\1", 2)
    ; Assign meta-sprite ID to name
    DEF METASPRITE_{NAME} EQU (@ - {METASPRITE_TABLE}) / 2
    
    ; Pointer to meta-sprite definition
    DW \1
ENDM
