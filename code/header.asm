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
    ldh     [hVBlankFlag], a
    ldh     [hNewKeys], a
    dec     a       ; a = $FF = all pressed
    ; Make all keys pressed so hNewKeys is correct
    ldh     [hPressedKeys], a
    
    ; Set current bank number
    ld      a, 1
    ldh     [hCurrentBank], a
    
    ; Set initial palettes
    ldh     a, [hConsoleType]
    and     a, a
    jr      z, .colour
    ld      a, %11100100
    ldh     [rBGP], a
    ldh     [rOBP1], a      ; Black, Dark gray, Light gray
    ld      a, %11010010
    ldh     [rOBP0], a      ; Black, Light gray, White
.colour
    ; TODO: Work out colour palettes
    jr      .donePalettes
    
.donePalettes
    ; Clear OAM
    ld      hl, _OAMRAM
    call    HideAllObjectsAtAddress
    ; Clear shadow OAM
    ld      hl, wShadowOAM
    ; a = 0
    ld      c, OAM_COUNT * sizeof_OAM_ATTRS
    rst     MemsetSmall
    
    ; Copy OAM DMA routine to HRAM
    ld      de, OAMDMA
    ld      hl, hOAMDMA
    ld      c, OAMDMA.end - OAMDMA
    call    MemcopySmall
    
    ; Initialize SoundSystem
    call    SoundSystem_Init
    ld      bc, BANK(SFX_Table)
    ld      de, SFX_Table
    call    SFX_Prepare
    
    ; Set all actors to empty
    ld      a, ACTOR_EMPTY
    ld      hl, wActorTypeTable
    ld      c, MAX_NUM_ACTORS
    rst     MemsetSmall
    
    ; Set up interrupts
    
    ; Update sound at every LY 0
    xor     a, a
    ldh     [rLYC], a
    ld      a, STATF_LYC
    ldh     [rSTAT], a
    
    ld      a, IEF_VBLANK | IEF_STAT
    ldh     [rIE], a
    ; Clear any pending interrupts
    xor     a, a
    ldh     [rIF], a
    ; Enable interrupts
    ei
    
    ; Turn on the LCD
    ld      a, LCDCF_ON | LCDCF_BG8800 | LCDCF_BG9800 | LCDCF_BGON | LCDCF_OBJ16 | LCDCF_OBJON
    ldh     [rLCDC], a
    
    ; Jump to the game select screen
    jp      GameSelect

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

; Current bank number of the $4000-$7FFF range, for interrupt handlers
; to restore
hCurrentBank::
    DS 1

; Temporary variable for whatever
hScratch::
    DS 1

SECTION UNION "Game Variables", HRAM

; Variables for whatever a game desires to use them for
; Not used anywhere outside of rhythm games
hGameVar1::
    DS 1
