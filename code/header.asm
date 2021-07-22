INCLUDE "constants/other-hardware.inc"

SECTION "Entry Point", ROM0[$0100]

EntryPoint:
    di
    jp      Initialize
    
    ; Ensure no space is wasted
    ASSERT @ == $0104

SECTION "Cartridge Header", ROM0[$0104]

; Leave room for the cartridge header, filled in by RGBFIX
CartridgeHeader:
    DS $0150 - $0104, 0

SECTION "Stack", WRAM0

    DS STACK_SIZE
wStackBottom::

SECTION "Keypad Variables", HRAM

; Currently pressed keys (1 = Pressed, 0 = Not pressed)
hPressedKeys::
    DS 1
; Keys that were just pressed this frame
hNewKeys::
    DS 1
; Keys that were just released this frame
hReleasedKeys::
    DS 1

SECTION "Current ROM Bank Number", HRAM

; Current bank number of the $4000-$7FFF range, for interrupt handlers
; to restore
hCurrentBank::
    DS 1

SECTION "Scratch Variables", HRAM

; Temporary variables for whatever
hScratch1::
    DS 1
hScratch2::
    DS 1
hScratch3::
    DS 1

SECTION "Random Number Variable", HRAM

; A random-ish number, modified when Random is called
hRandomNumber::
    DS 1

SECTION "Hardware Register Mirrors", HRAM

; Mirrors of hardware registers, copied to the real things in the VBlank
; interrupt handler

hLCDC::
    DS 1

hSCX::
    DS 1
hSCY::
    DS 1

hBGP::
    DS 1
hOBP0::
    DS 1
hOBP1::
    DS 1

SECTION "Current Game ID", HRAM

; The ID of the current game
; See constants/games.inc for possible values
hCurrentGame::
    DS 1
