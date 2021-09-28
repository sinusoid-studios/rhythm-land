INCLUDE "constants/hardware.inc"
INCLUDE "constants/transition.inc"
INCLUDE "constants/screens.inc"
INCLUDE "constants/games/skater-dude.inc"

SECTION "Pause", ROM0

Pause::
    call    Music_Pause
    
.loop
    rst     WaitVBlank
    
    ; Check for resume or quit
    ldh     a, [hNewKeys]
    bit     PADB_START, a
    jr      z, .loop
    
    ; Resume = START; Quit = SELECT+START
    ldh     a, [hPressedKeys]
    ; Check if SELECT is held
    bit     PADB_SELECT, a
    ; No SELECT -> resume music and return to game
    jp      z, Music_Resume
    
    ; Quit game
    ; Trash return address
    pop     af
    ; Return to game select
    ld      a, SCREEN_GAME_SELECT
    call    TransitionStart
    ; Not enough time to do Skater Dude's building bounce during a
    ; transition, so stop the bounce
    ld      a, BUILDING_NOT_BOUNCING
    ldh     [hBuildingBounceIndex], a
    xor     a, a
    ldh     [hSCY], a
.transitionLoop
    rst     WaitVBlank
    call    TransitionUpdate
    jr      .transitionLoop
