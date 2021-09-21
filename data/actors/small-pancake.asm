INCLUDE "constants/hardware.inc"
INCLUDE "constants/actors.inc"
INCLUDE "macros/actors.inc"

SECTION "Small Pancake Actor Animation Data", ROMX

xActorSmallPancakeAnimation::
    animation SmallPancake

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
.flip1Perfect
    INCBIN "res/pancake/small-pancake/flip-1-perfect.obj.2bpp", 2 * 16
.flip1Overcooked
    INCBIN "res/pancake/small-pancake/flip-1-overcooked.obj.2bpp", 2 * 16
.flip2Undercooked
    INCBIN "res/pancake/small-pancake/flip-2-undercooked.obj.2bpp"
.flip2Perfect
    INCBIN "res/pancake/small-pancake/flip-2-perfect.obj.2bpp"
.flip2Overcooked
    INCBIN "res/pancake/small-pancake/flip-2-overcooked.obj.2bpp"
.flip3Undercooked
    INCBIN "res/pancake/small-pancake/flip-3-undercooked.obj.2bpp"
.flip3Perfect
    INCBIN "res/pancake/small-pancake/flip-3-perfect.obj.2bpp"
.flip3Overcooked
    INCBIN "res/pancake/small-pancake/flip-3-overcooked.obj.2bpp"

SECTION "Small Pancake Actor Meta-Sprite Data", ROMX

xActorSmallPancakeMetasprites::
    metasprite .falling1
    metasprite .falling2
    metasprite .cookingFlip23
    metasprite .cookingFlip23Pal1
    metasprite .flip1
    metasprite .flip1Pal1

.falling1
    obj 0, 0, $00, 0
    DB METASPRITE_END
.falling2
    obj 0, 0, $02, 0
    obj 0, 8, $04, 0
    DB METASPRITE_END
.cookingFlip23
    ; Used by "very undercooked", "undercooked", "perfect",
    ; "overcooked", and "flip [23] (undercooked|perfect)"
    obj 0, 0, $00, 0
    obj 0, 8, $02, 0
    obj 0, 16, $04, 0
    DB METASPRITE_END
.cookingFlip23Pal1
    ; Used by "very overcooked", "burnt", and "flip [23] overcooked"
    obj 0, 0, $00, OAMF_PAL1
    obj 0, 8, $02, OAMF_PAL1
    obj 0, 16, $04, OAMF_PAL1
    DB METASPRITE_END

.flip1
    obj 0, 4, $00, 0
    obj 0, 12, $02, 0
    obj 16, 0, $04, 0
    obj 16, 8, $06, 0
    obj 16, 16, $08, 0
    DB METASPRITE_END
.flip1Pal1
    obj 0, 4, $00, OAMF_PAL1
    obj 0, 12, $02, OAMF_PAL1
    obj 16, 0, $04, OAMF_PAL1
    obj 16, 8, $06, OAMF_PAL1
    obj 16, 16, $08, OAMF_PAL1
    DB METASPRITE_END
