INCLUDE "constants/hardware.inc"
INCLUDE "constants/actors.inc"
INCLUDE "macros/actors.inc"

SECTION "Large Pancake Actor Animation Data", ROMX

xActorLargePancakeAnimation::
    animation LargePancake

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
.flip1Perfect
    INCBIN "res/pancake/large-pancake/flip-1-perfect.obj.2bpp", 2 * 16
.flip1Overcooked
    INCBIN "res/pancake/large-pancake/flip-1-overcooked.obj.2bpp", 2 * 16
.flip2Undercooked
    INCBIN "res/pancake/large-pancake/flip-2-undercooked.obj.2bpp"
.flip2Perfect
    INCBIN "res/pancake/large-pancake/flip-2-perfect.obj.2bpp"
.flip2Overcooked
    INCBIN "res/pancake/large-pancake/flip-2-overcooked.obj.2bpp"
.flip3Undercooked
    INCBIN "res/pancake/large-pancake/flip-3-undercooked.obj.2bpp"
.flip3Perfect
    INCBIN "res/pancake/large-pancake/flip-3-perfect.obj.2bpp"
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
    obj 0, 0, $00, 0
    obj 0, 8, $02, 0
    DB METASPRITE_END
.falling2
    obj 0, 0, $04, 0
    obj 0, 8, $06, 0
    obj 0, 16, $08, 0
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
    obj 0, 4, $00, 0
    obj 0, 12, $02, 0
    obj 0, 20, $04, 0
    obj 16, 0, $06, 0
    obj 16, 8, $08, 0
    obj 16, 16, $0A, 0
    obj 16, 24, $0C, 0
    DB METASPRITE_END
.flip1Pal1
    obj 0, 4, $00, OAMF_PAL1
    obj 0, 12, $02, OAMF_PAL1
    obj 0, 20, $04, OAMF_PAL1
    obj 16, 0, $06, OAMF_PAL1
    obj 16, 8, $08, OAMF_PAL1
    obj 16, 16, $0A, OAMF_PAL1
    obj 16, 24, $0C, OAMF_PAL1
    DB METASPRITE_END
.flip23
    ; Used for both the 2nd and 3rd flip cels
    obj 0, 0, $00, 0
    obj 0, 8, $02, 0
    obj 0, 16, $04, 0
    obj 0, 24, $06, 0
    DB METASPRITE_END
.flip23Pal1
    obj 0, 0, $00, OAMF_PAL1
    obj 0, 8, $02, OAMF_PAL1
    obj 0, 16, $04, OAMF_PAL1
    obj 0, 24, $06, OAMF_PAL1
    DB METASPRITE_END
