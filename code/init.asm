INCLUDE "constants/hardware.inc"
INCLUDE "constants/actors.inc"
INCLUDE "constants/screens.inc"
INCLUDE "constants/transition.inc"
INCLUDE "constants/interrupts.inc"

SECTION "Initialization", ROM0

Initialize::
    ; Interrupts disabled from entry point
    
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
    ldh     [hLYCFlag], a
    ldh     [hNextHitKeys], a
    ldh     [hSCX], a
    ldh     [rSCX], a
    ldh     [hSCY], a
    ldh     [rSCY], a
    ; TODO: Use a player-reliant seed
    ldh     [hRandomNumber], a
    ASSERT TRANSITION_STATE_OFF == 0
    ldh     [hTransitionState], a
    
    ldh     [hNewKeys], a
    dec     a       ; a = $FF = all pressed
    ; Make all keys pressed so hNewKeys is correct
    ldh     [hPressedKeys], a
    
    ; Disable extra LYC interrupts
    ASSERT LYC_INDEX_NONE == -1
    ldh     [hLYCIndex], a
    ldh     [hLYCResetIndex], a
    
    ; Reset frame counter
    xor     a, a
    ldh     [hFrameCounter], a
    
    ; Set current bank number
    inc     a   ; a = 1
    ldh     [hCurrentBank], a
    
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
    ld      c, BANK(SFX_Table)
    ld      de, SFX_Table
    call    SFX_Prepare
    
    ; Set all actors to empty
    ld      a, ACTOR_EMPTY
    ld      hl, wActorTypeTable
    ld      c, MAX_ACTOR_COUNT
    rst     MemsetSmall
    ; Reset all actor speed fractional accumulators
    xor     a, a
    ld      hl, wActorXSpeedAccTable
    ASSERT wActorYSpeedAccTable == wActorXSpeedAccTable + MAX_ACTOR_COUNT
    ld      c, MAX_ACTOR_COUNT * 2
    rst     MemsetSmall
    
    ; Initialize text engine
    ; a = 0
    ld      [wTextCurPixel], a
    ld      [wTextCharset], a
    ; a = 0
    ld      c, $10 * 2
    ld      hl, wTextTileBuffer
    rst     MemsetSmall
    
    ; Detect bad emulators
    ; Although this doesn't actually test specific things that are
    ; required to run the game, it's important to 1) prevent bad
    ; emulators from ruining the game in other places and 2) get more
    ; people to switch to more accurate emulators anyway.
    
    ; Test 1: Non-existent flag bits
    ; The low 4 bits of F in AF should always be 0
    ld      hl, $9C47   ; This value has no significance
    push    hl
    pop     af      ; AF should now be $9C40
    ; Move AF into a register pair (DE here)
    push    af
    pop     de
    ; H and D matching isn't the focus of this, but if they don't match,
    ; that's a big problem
    ld      a, h    ; h = $9C
    cp      a, d    ; D should also be $9C
    jp      nz, BadEmulator
    ; Check if the low 4 bits of F in AF are all 0
    ld      a, l    ; l = $47
    and     a, $F0  ; a = $40
    cp      a, e    ; E should be $40
    jp      nz, BadEmulator
    
    ; Test 2: Unused hardware register bits
    ; SC bits 6-2 are unused and should always read back 1
    xor     a, a
    ldh     [rSC], a
    ldh     a, [rSC]
    and     a, %01111100
    cp      a, %01111100
    jp      nz, BadEmulator
    
    ; If the program runs to here, the game will hopefully play
    ; accurately
    
    ; Verify save data
    ld      a, CART_SRAM_ENABLE
    ld      [rRAMG], a
    
    ; Calculate the save data check value
    call    CalcSaveCheck
    ; Compare it with the saved copy of the check value
    ld      hl, sCheck
    ; de = check value
    ld      a, e
    cp      a, [hl]
    jr      nz, .badSave
    ASSERT HIGH(sCheck.high) == HIGH(sCheck.low)
    inc     l
    ld      a, d
    cp      a, [hl]
    jr      z, .saveOK
    
.badSave
    ; The save data check value is incorrect -> initialize save data
    ld      hl, sSaveData
    ld      c, sSaveDataEnd - sSaveData
    xor     a, a
    rst     MemsetSmall
    ; Update check value
    call    CalcSaveCheck
    ld      a, e
    ld      [sCheck.low], a
    ld      a, d
    ld      [sCheck.high], a
.saveOK
    ASSERT CART_SRAM_DISABLE == 0
    xor     a, a
    ld      [rRAMG], a
    
    ; Starting with the title screen -> set it up
    ld      a, SCREEN_TITLE
    ldh     [hCurrentScreen], a
    call    ScreenSetupTitle
    ; Set initial palettes that the title screen doesn't set up
    ld      a, %11_10_01_00 ; Black, Dark gray, Light gray
    ldh     [hOBP1], a
    
    ; Set up interrupts
    
    ; Set the STAT interrupt source now so that it doesn't have to be
    ; set every time LYC interrupts are needed
    ld      a, STATF_LYC
    ldh     [rSTAT], a
    
    ld      a, IEF_VBLANK
    ldh     [rIE], a
    ; Clear any pending interrupts
    xor     a, a
    ldh     [rIF], a
    ; Enable interrupts
    ei
    
    ; Turn on the LCD (title screen setup set hLCDC)
    ldh     a, [hLCDC]
    ldh     [rLCDC], a
    
    ; Jump to the title screen
    jp      ScreenTitle
