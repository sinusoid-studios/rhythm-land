INCLUDE "macros/misc.inc"

SECTION "Rating Screen Tiles Table", ROM0

RatingTilesTable::
    full_pointer xRatingTilesBad
    DW SIZEOF("Rating Screen Bad Tiles")
    full_pointer xRatingTilesOK
    DW SIZEOF("Rating Screen OK Tiles")
    full_pointer xRatingTilesGreat
    DW SIZEOF("Rating Screen Great Tiles")
    full_pointer xRatingTilesPerfect
    DW SIZEOF("Rating Screen Perfect Tiles")
.end::

SECTION "Rating Screen Theme Table", ROM0

RatingThemeTable::
    ; TODO: Make Bad and Perfect themes
    ; For now just use the file select theme because I don't know what
    ; else to use. It's only temporary.
    
    ; full_pointer Inst_Bad, Music_Bad
    full_pointer Inst_FileSelect, Music_FileSelect
    full_pointer Inst_OK, Music_OK
    full_pointer Inst_Great, Music_Great
    ; full_pointer Inst_Perfect, Music_Perfect
    full_pointer Inst_FileSelect, Music_FileSelect
.end::

SECTION "Rating Screen Bad Tiles", ROMX

xRatingTilesBad:
    INCBIN "res/ratings/bad.bg.2bpp"

SECTION "Rating Screen OK Tiles", ROMX

xRatingTilesOK:
    INCBIN "res/ratings/ok.bg.2bpp"

SECTION "Rating Screen Great Tiles", ROMX

xRatingTilesGreat:
    INCBIN "res/ratings/great.bg.2bpp"

SECTION "Rating Screen Perfect Tiles", ROMX

xRatingTilesPerfect:
    INCBIN "res/ratings/perfect.bg.2bpp"

SECTION "Rating Screen Map Table", ROM0

RatingMapTable::
    full_pointer xRatingMapBad
    full_pointer xRatingMapOK
    full_pointer xRatingMapGreat
    full_pointer xRatingMapPerfect
.end::

SECTION "Rating Screen Bad Map", ROMX

xRatingMapBad:
    INCBIN "res/ratings/bad.bg.tilemap"

SECTION "Rating Screen OK Map", ROMX

xRatingMapOK:
    INCBIN "res/ratings/ok.bg.tilemap"

SECTION "Rating Screen Great Map", ROMX

xRatingMapGreat:
    INCBIN "res/ratings/great.bg.tilemap"

SECTION "Rating Screen Perfect Map", ROMX

xRatingMapPerfect:
    INCBIN "res/ratings/perfect.bg.tilemap"
