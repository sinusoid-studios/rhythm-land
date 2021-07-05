INCLUDE "defines.inc"

SECTION "Initialization", ROM0[$0100]

EntryPoint:
    ; Allow checking for CGB more efficiently
    sub     a, BOOTUP_A_CGB
    jr      Initialize
    
    ; Ensure no space is wasted
    ASSERT @ == $0104

CartridgeHeader:
    ; Leave room for the cartridge header, filled in by RGBFIX
    DS $0150 - @, 0

Initialize::
    ; Save console type for future reference
    ldh     [hConsoleType], a
    
    ; Disable interrupts during setup
    di
    
.waitVBL
    ; Wait for VBlank and disable the LCD
    ldh     a, [rLY]
    cp      a, SCRN_Y
    jr      c, .waitVBL
    xor     a, a
    ldh     [rLCDC], a
    
    ; Set stack pointer
    ld      sp, wStackBottom
    
    ; Reset variables
    ; a = 0
    ldh     [hNewKeys], a
    dec     a       ; a = $FF = all pressed
    ; Make all keys pressed so hNewKeys is correct
    ldh     [hPressedKeys], a
    
    ; Set up interrupts
    ld      a, IEF_VBLANK
    ldh     [rIE], a
    ; Clear any pending interrupts
    xor     a, a
    ldh     [rIF], a
    ; Enable interrupts
    ei
    
    ; Turn on the LCD
    ld      a, LCDCF_ON
    ldh     [rLCDC], a

Lockup:
    ; Wait for VBlank
    halt
    jr      Lockup

SECTION "Stack", WRAM0

    DS STACK_SIZE
wStackBottom::

SECTION "Global Variables", HRAM

; Zero if running on a CGB, non-zero otherwise
hConsoleType::
    DS 1

; Currently pressed keys (1 = Pressed, 0 = Not pressed)
hPressedKeys::
    DS 1
; Keys that were just pressed this frame
hNewKeys::
    DS 1
