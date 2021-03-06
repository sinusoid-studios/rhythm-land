INCLUDE "constants/hardware.inc"
INCLUDE "constants/games/pancake.inc"
INCLUDE "constants/actors.inc"
INCLUDE "macros/actors.inc"

SECTION "Small Pancake Actor Animation Data", ROMX

xActorSmallPancakeAnimation::
    animation SmallPancake

    ; Falling and cooking sequence
    set_tiles falling, 6
    cel falling1, 10
    cel falling2, 10
.cook
    DEF COOK_CEL_TIME EQU (SMALL_PANCAKE_COOK_TIME - 10 * 2) / 6
    
    set_tiles landed, 6
    cel cooking, SMALL_PANCAKE_COOK_TIME / 6
    set_tiles veryUndercooked, 6
    cel cooking, SMALL_PANCAKE_COOK_TIME / 6
    set_tiles undercooked, 6
    cel cooking, SMALL_PANCAKE_COOK_TIME / 6
    set_tiles perfect, 6
    cel cooking, SMALL_PANCAKE_COOK_TIME / 6
    set_tiles overcooked, 6
    cel cooking, SMALL_PANCAKE_COOK_TIME / 6
    set_tiles veryOvercooked, 6
    cel cookingPal1, SMALL_PANCAKE_COOK_TIME / 6
    set_tiles burnt, 6
    cel cookingPal1, 40
    DB ANIMATION_KILL_ACTOR

    ; Fix alignment
    DS 1
.flipUndercooked
    set_tiles flip1Undercooked, 10
    cel flip1, 4
    set_tiles flip2Undercooked, 6
    cel flip23, 4
    set_tiles flip3Undercooked, 6
    cel flip23, 3
    goto_cel .cook

.flipOK
    set_tiles flip1OK, 10
    cel flip1, 4
    set_tiles flip2OK, 6
    cel flip23, 4
    set_tiles flip3OK, 6
    cel flip23, 3
    goto_cel .cook

.flipOvercooked
    set_tiles flip1Overcooked, 10
    cel flip1Pal1, 4
    set_tiles flip2Overcooked, 6
    cel flip23Pal1, 4
    set_tiles flip3Overcooked, 6
    cel flip23Pal1, 3
    goto_cel .cook

xActorSmallPancakeTiles::
.falling
    INCBIN "res/pancake/small-pancake/falling.obj.2bpp"
.landed
    INCBIN "res/pancake/small-pancake/landed.obj.2bpp"
.veryUndercooked
    INCBIN "res/pancake/small-pancake/very-undercooked.obj.2bpp"
.undercooked
    INCBIN "res/pancake/small-pancake/undercooked.obj.2bpp"
.perfect
    INCBIN "res/pancake/small-pancake/perfect.obj.2bpp"
.overcooked
    INCBIN "res/pancake/small-pancake/overcooked.obj.2bpp"
.veryOvercooked
    INCBIN "res/pancake/small-pancake/very-overcooked.obj.2bpp"
.burnt
    INCBIN "res/pancake/small-pancake/burnt.obj.2bpp"
.flip1Undercooked
    INCBIN "res/pancake/small-pancake/flip-1-undercooked.obj.2bpp", 2 * 16
.flip1OK
    INCBIN "res/pancake/small-pancake/flip-1-ok.obj.2bpp", 2 * 16
.flip1Overcooked
    INCBIN "res/pancake/small-pancake/flip-1-overcooked.obj.2bpp", 2 * 16
.flip2Undercooked
    INCBIN "res/pancake/small-pancake/flip-2-undercooked.obj.2bpp"
.flip2OK
    INCBIN "res/pancake/small-pancake/flip-2-ok.obj.2bpp"
.flip2Overcooked
    INCBIN "res/pancake/small-pancake/flip-2-overcooked.obj.2bpp"
.flip3Undercooked
    INCBIN "res/pancake/small-pancake/flip-3-undercooked.obj.2bpp"
.flip3OK
    INCBIN "res/pancake/small-pancake/flip-3-ok.obj.2bpp"
.flip3Overcooked
    INCBIN "res/pancake/small-pancake/flip-3-overcooked.obj.2bpp"

SECTION "Small Pancake Actor Meta-Sprite Data", ROMX

xActorSmallPancakeMetasprites::
    metasprite .falling1
    metasprite .falling2
    metasprite .cooking
    metasprite .cookingPal1
    metasprite .flip1
    metasprite .flip1Pal1
    metasprite .flip23
    metasprite .flip23Pal1

.falling1
    obj 9, 12, $00, 0
    DB METASPRITE_END
.falling2
    obj 9, 8, $02, 0
    obj 9, 16, $04, 0
    DB METASPRITE_END
.cooking
    ; Used by "very undercooked", "undercooked", "perfect", and
    ; "overcooked"
    obj 12, 4, $00, 0
    obj 12, 12, $02, 0
    obj 12, 20, $04, 0
    DB METASPRITE_END
.cookingPal1
    ; Used by "very overcooked" and "burnt"
    obj 12, 4, $00, OAMF_PAL1
    obj 12, 12, $02, OAMF_PAL1
    obj 12, 20, $04, OAMF_PAL1
    DB METASPRITE_END

.flip1
    obj -8, 8, $00, 0
    obj -8, 16, $02, 0
    obj 8, 4, $04, 0
    obj 8, 12, $06, 0
    obj 8, 20, $08, 0
    DB METASPRITE_END
.flip1Pal1
    obj -8, 8, $00, OAMF_PAL1
    obj -8, 16, $02, OAMF_PAL1
    obj 8, 4, $04, OAMF_PAL1
    obj 8, 12, $06, OAMF_PAL1
    obj 8, 20, $08, OAMF_PAL1
    DB METASPRITE_END

.flip23
    ; Used by "flip [23] (undercooked|perfect)"
    obj -10, 4, $00, 0
    obj -10, 12, $02, 0
    obj -10, 20, $04, 0
    DB METASPRITE_END
.flip23Pal1
    ; Used by "flip [23] overcooked"
    obj -10, 4, $00, OAMF_PAL1
    obj -10, 12, $02, OAMF_PAL1
    obj -10, 20, $04, OAMF_PAL1
    DB METASPRITE_END
