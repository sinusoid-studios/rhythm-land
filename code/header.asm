INCLUDE "defines.inc"

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

SECTION "Global Variables", HRAM

; Currently pressed keys (1 = Pressed, 0 = Not pressed)
hPressedKeys::
    DS 1
; Keys that were just pressed this frame
hNewKeys::
    DS 1
; Keys that were just released this frame
hReleasedKeys::
    DS 1

; Current bank number of the $4000-$7FFF range, for interrupt handlers
; to restore
hCurrentBank::
    DS 1

; Temporary variables for whatever
hScratch1::
    DS 1
hScratch2::
    DS 1

; Mirrors of rSCX and rSCY, copied to rSCX and rSCY in the VBlank
; interrupt handler
hSCX::
    DS 1
hSCY::
    DS 1

; The ID of the current game
; See constants/games.inc for possible values
hGameID::
    DS 1
