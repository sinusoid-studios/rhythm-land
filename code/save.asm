INCLUDE "constants/screens.inc"

SECTION "Save Data Check Value Calculation", ROM0

; @return   de  16-bit check value of save data
CalcSaveCheck::
    ld      hl, sSaveData
    ld      de, 0
    ld      c, sSaveDataEnd - sSaveData
.loop
    ; Add [hl] to de << 1
    ld      a, e
    ; de <<= 1
    add     a, a
    rl      d
    ; de += [hl]
    add     a, [hl]
    ASSERT HIGH(sSaveDataEnd - 1) == HIGH(sSaveData)
    inc     l
    ld      e, a
    adc     a, d
    sub     a, e
    ; Introduce some sort of address dependancy (this is why it's not a
    ; "checksum")
    xor     a, l
    ld      d, a
    
    dec     c
    jr      nz, .loop
    ret

SECTION "Save Data Check Value", SRAM

sCheck::
.low::
    DS 1
.high::
    DS 1

SECTION "Save Data", SRAM

sSaveData::

sRatingTable::
    DS GAME_COUNT
.end::

sSaveDataEnd::
