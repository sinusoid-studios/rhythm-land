INCLUDE "defines.inc"

SECTION "Initialization", ROM0

Initialize::
    ; Wait for VBlank and disable the LCD
    ldh     a, [rLY]
    cp      a, SCRN_Y
    jr      c, Initialize
    xor     a, a
    ldh     [rLCDC], a
    
    ; Set stack pointer
    ld      sp, wStackBottom
    
    ; Reset variables
    ; a = 0
    ldh     [hVBlankFlag], a
    ldh     [hNextHitKeys], a
    ldh     [hSCX], a
    ldh     [hSCY], a
    ; TODO: Use a player-reliant seed
    ldh     [hRandomNumber], a
    
    ldh     [hNewKeys], a
    dec     a       ; a = $FF = all pressed
    ; Make all keys pressed so hNewKeys is correct
    ldh     [hPressedKeys], a
    
    ; Set current bank number
    ld      a, 1
    ldh     [hCurrentBank], a
    
    ; Set initial palettes
    ld      a, %11100100
    ldh     [rBGP], a
    ldh     [rOBP1], a      ; Black, Dark gray, Light gray
    ld      a, %11010010
    ldh     [rOBP0], a      ; Black, Light gray, White
    
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
    
    ; Fill the window black
    ; TODO: Find something better
    
    ; Black tile
    ld      hl, $8FF0
    ld      a, $FF
    ld      c, 16
    rst     MemsetSmall
    ; Fill window tilemap
    ld      hl, _SCRN1
    ; a = $FF
    lb      bc, HIGH(SCRN_VX_B * SCRN_Y_B) + 1, LOW(SCRN_VX_B * SCRN_Y_B)
.loop
    ld      [hli], a
    dec     c
    jr      nz, .loop
    dec     b
    jr      nz, .loop
    
    ; Initialize SoundSystem
    call    SoundSystem_Init
    ld      c, BANK(SFX_Table)
    ld      de, SFX_Table
    call    SFX_Prepare
    
    ; Set all actors to empty
    ld      a, ACTOR_EMPTY
    ld      hl, wActorTypeTable
    ld      c, MAX_NUM_ACTORS
    rst     MemsetSmall
    ; Reset all actor speed fractional accumulators
    xor     a, a
    ld      hl, wActorXSpeedAccTable
    ASSERT wActorYSpeedAccTable == wActorXSpeedAccTable + MAX_NUM_ACTORS
    ld      c, MAX_NUM_ACTORS * 2
    rst     MemsetSmall
    
    ; Starting with the title screen -> set it up
    call    SetupTitleScreen
    
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
    ld      a, LCDCF_ON | LCDCF_BG8800 | LCDCF_BG9800 | LCDCF_BGON | LCDCF_WIN9C00 | LCDCF_OBJ16 | LCDCF_OBJON
    ldh     [rLCDC], a
    
    ; Jump to the title screen
    jp      TitleScreen
