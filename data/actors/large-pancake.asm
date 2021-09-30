INCLUDE "constants/hardware.inc"
INCLUDE "constants/games/pancake.inc"
INCLUDE "constants/actors.inc"
INCLUDE "macros/actors.inc"

SECTION "Large Pancake Actor Animation Data", ROMX

xActorLargePancakeAnimation::
    animation LargePancake, PANCAKE

    ; Falling and cooking sequence
    set_tiles falling, 10
    cel falling1, LARGE_PANCAKE_COOK_TIME / 8
    cel falling2, LARGE_PANCAKE_COOK_TIME / 8
.cook
    set_tiles landed, 12
    cel cooking, LARGE_PANCAKE_COOK_TIME / 8
.OK
    set_tiles veryUndercooked, 12
    cel cooking, LARGE_PANCAKE_COOK_TIME / 8
    set_tiles undercooked, 12
    cel cooking, LARGE_PANCAKE_COOK_TIME / 8
.cookedOK
    set_tiles perfect, 12
    cel cooking, LARGE_PANCAKE_COOK_TIME / 8
    set_tiles overcooked, 12
    cel cooking, LARGE_PANCAKE_COOK_TIME / 8
.overcooked
    set_tiles veryOvercooked, 12
    cel cookingPal1, LARGE_PANCAKE_COOK_TIME / 8
    set_tiles burnt, 12
    cel cookingPal1, 40
    DB ANIMATION_KILL_ACTOR

    ; Fix alignment
    DS 1
.flipUndercooked
    set_tiles flip1Undercooked, 14
    cel flip1, 4
    set_tiles flip2Undercooked, 8
    cel flip23, 4
    set_tiles flip3Undercooked, 8
    cel flip23, 3
    goto_cel .cook

.flipOK
    set_tiles flip1OK, 14
    cel flip1, 4
    set_tiles flip2OK, 8
    cel flip23, 4
    set_tiles flip3OK, 8
    cel flip23, 3
    goto_cel .cook

.flipOvercooked
    set_tiles flip1Overcooked, 14
    cel flip1Pal1, 4
    set_tiles flip2Overcooked, 8
    cel flip23Pal1, 4
    set_tiles flip3Overcooked, 8
    cel flip23Pal1, 3
    goto_cel .cook

    ; Cel constant definitions
    def_cel .OK, OK
    def_cel .overcooked, OVERCOOKED
    def_cel .flipUndercooked, FLIP_UNDERCOOKED
    def_cel .flipOK, FLIP_OK
    def_cel .flipOvercooked, FLIP_OVERCOOKED
    def_cel .OK, COOKED_UNDERCOOKED
    def_cel .cookedOK, COOKED_OK
    def_cel .overcooked, COOKED_OVERCOOKED

xActorLargePancakeTiles::
.falling
    INCBIN "res/pancake/large-pancake/falling.obj.2bpp"
.landed
    INCBIN "res/pancake/large-pancake/landed.obj.2bpp", 2 * 16
.veryUndercooked
    INCBIN "res/pancake/large-pancake/very-undercooked.obj.2bpp", 2 * 16
.undercooked
    INCBIN "res/pancake/large-pancake/undercooked.obj.2bpp", 2 * 16
.perfect
    INCBIN "res/pancake/large-pancake/perfect.obj.2bpp", 2 * 16
.overcooked
    INCBIN "res/pancake/large-pancake/overcooked.obj.2bpp", 2 * 16
.veryOvercooked
    INCBIN "res/pancake/large-pancake/very-overcooked.obj.2bpp", 2 * 16
.burnt
    INCBIN "res/pancake/large-pancake/burnt.obj.2bpp", 2 * 16
.flip1Undercooked
    INCBIN "res/pancake/large-pancake/flip-1-undercooked.obj.2bpp", 2 * 16
.flip1OK
    INCBIN "res/pancake/large-pancake/flip-1-ok.obj.2bpp", 2 * 16
.flip1Overcooked
    INCBIN "res/pancake/large-pancake/flip-1-overcooked.obj.2bpp", 2 * 16
.flip2Undercooked
    INCBIN "res/pancake/large-pancake/flip-2-undercooked.obj.2bpp"
.flip2OK
    INCBIN "res/pancake/large-pancake/flip-2-ok.obj.2bpp"
.flip2Overcooked
    INCBIN "res/pancake/large-pancake/flip-2-overcooked.obj.2bpp"
.flip3Undercooked
    INCBIN "res/pancake/large-pancake/flip-3-undercooked.obj.2bpp"
.flip3OK
    INCBIN "res/pancake/large-pancake/flip-3-ok.obj.2bpp"
.flip3Overcooked
    INCBIN "res/pancake/large-pancake/flip-3-overcooked.obj.2bpp"

SECTION "Large Pancake Actor Meta-Sprite Data", ROMX

xActorLargePancakeMetasprites::
    metasprite .falling1
    metasprite .falling2
    metasprite .cooking
    metasprite .cookingPal1
    metasprite .flip1
    metasprite .flip1Pal1
    metasprite .flip23
    metasprite .flip23Pal1

.falling1
    obj 14, 8, $00, 0
    obj 14, 16, $02, 0
    DB METASPRITE_END
.falling2
    obj 14, 4, $04, 0
    obj 14, 12, $06, 0
    obj 14, 20, $08, 0
    DB METASPRITE_END
.cooking
    ; Used by "very undercooked", "undercooked", "perfect", and
    ; "overcooked"
    obj 0, 8, $00, 0
    obj 0, 16, $02, 0
    obj 16, 0, $04, 0
    obj 16, 8, $06, 0
    obj 16, 16, $08, 0
    obj 16, 24, $0A, 0
    DB METASPRITE_END
.cookingPal1
    ; Used by "very overcooked" and "burnt"
    obj 0, 8, $00, OAMF_PAL1
    obj 0, 16, $02, OAMF_PAL1
    obj 16, 0, $04, OAMF_PAL1
    obj 16, 8, $06, OAMF_PAL1
    obj 16, 16, $08, OAMF_PAL1
    obj 16, 24, $0A, OAMF_PAL1
    DB METASPRITE_END

.flip1
    obj -6, 4, $00, 0
    obj -6, 12, $02, 0
    obj -6, 20, $04, 0
    obj 10, 0, $06, 0
    obj 10, 8, $08, 0
    obj 10, 16, $0A, 0
    obj 10, 24, $0C, 0
    DB METASPRITE_END
.flip1Pal1
    obj -6, 4, $00, OAMF_PAL1
    obj -6, 12, $02, OAMF_PAL1
    obj -6, 20, $04, OAMF_PAL1
    obj 10, 0, $06, OAMF_PAL1
    obj 10, 8, $08, OAMF_PAL1
    obj 10, 16, $0A, OAMF_PAL1
    obj 10, 24, $0C, OAMF_PAL1
    DB METASPRITE_END
.flip23
    ; Used for both the 2nd and 3rd flip cels
    obj -10, 0, $00, 0
    obj -10, 8, $02, 0
    obj -10, 16, $04, 0
    obj -10, 24, $06, 0
    DB METASPRITE_END
.flip23Pal1
    obj -10, 0, $00, OAMF_PAL1
    obj -10, 8, $02, OAMF_PAL1
    obj -10, 16, $04, OAMF_PAL1
    obj -10, 24, $06, OAMF_PAL1
    DB METASPRITE_END
