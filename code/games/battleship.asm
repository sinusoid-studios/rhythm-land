INCLUDE "constants/hardware.inc"
INCLUDE "constants/transition.inc"
INCLUDE "constants/games/battleship.inc"
INCLUDE "constants/actors.inc"
INCLUDE "constants/sfx.inc"
INCLUDE "constants/engine.inc"

SECTION "Battleship Game Setup", ROMX

xGameSetupBattleship::
    ; Set palettes
    ld      a, BATTLESHIP_BGP
    ldh     [hBGP], a
    ld      a, BATTLESHIP_OBP0
    ldh     [hOBP0], a
    ld      a, BATTLESHIP_OBP1
    ldh     [hOBP1], a
    
    ; Set appropriate LCDC flags
    ld      a, LCDCF_ON | LCDCF_BG8800 | LCDCF_BG9800 | LCDCF_BGON | LCDCF_OBJ16 | LCDCF_OBJON
    ldh     [hLCDC], a
    
    ; Set initial Y scroll
    ld      a, BATTLESHIP_INITIAL_Y
    ldh     [hSCY], a
    
    ; Load background tiles
    ASSERT BANK(xBackgroundTiles) == BANK(@)
    ld      de, xBackgroundTiles
    ld      hl, $9000
    ld      bc, xBackgroundTiles.end - xBackgroundTiles
    rst     LCDMemcopy
    
    ; Load sprite tiles
    ASSERT BANK(xSpriteTiles) == BANK(@)
    ASSERT xSpriteTiles == xBackgroundTiles.end
    ; de = xSpriteTiles
    ld      hl, $8000
    ld      bc, xSpriteTiles.end - xSpriteTiles
    rst     LCDMemcopy
    
    ; Repeat the 6-tile-high ocean pattern 3 times vertically onto the
    ; tilemap
    ASSERT BATTLESHIP_OCEAN_SIZE * 3 == SCRN_Y_B
    
    ; Load first background map
    ASSERT BANK(xMap1) == BANK(@)
    ASSERT xMap1 == xSpriteTiles.end
    ; de = xMap1
    ld      hl, _SCRN0
    ld      c, BATTLESHIP_OCEAN_SIZE
    call    LCDMemcopyMap
    ld      de, xMap1
    ld      c, BATTLESHIP_OCEAN_SIZE
    call    LCDMemcopyMap
    ld      de, xMap1
    ld      c, BATTLESHIP_OCEAN_SIZE
    call    LCDMemcopyMap
    ; 1 extra time for scrolling
    ld      de, xMap1
    ld      c, BATTLESHIP_OCEAN_SIZE
    call    LCDMemcopyMap
    ; Load second background map
    ASSERT BANK(xMap2) == BANK(@)
    ASSERT xMap2 == xMap1.end
    ; de = xMap2
    ld      hl, _SCRN1
    ld      c, BATTLESHIP_OCEAN_SIZE
    call    LCDMemcopyMap
    ld      de, xMap2
    ld      c, BATTLESHIP_OCEAN_SIZE
    call    LCDMemcopyMap
    ld      de, xMap2
    ld      c, BATTLESHIP_OCEAN_SIZE
    call    LCDMemcopyMap
    ; 1 extra time for scrolling
    ld      de, xMap2
    ld      c, BATTLESHIP_OCEAN_SIZE
    call    LCDMemcopyMap
    
    ; Create the Ship actor
    ASSERT BANK(xActorShipCannonDefinition) == BANK(@)
    ld      de, xActorShipCannonDefinition
    call    ActorNew
    ASSERT BANK(xActorShipDefinition) == BANK(@)
    ASSERT xActorShipDefinition == xActorShipCannonDefinition.end
    ; de = xActorShipDefinition
    call    ActorNew
    
    ; Set up game data
    ld      c, BANK(xHitTableBattleship)
    ld      hl, xHitTableBattleship
    jp      EngineInit

xBackgroundTiles:
    INCBIN "res/battleship/background.bg.2bpp"
.end

xSpriteTiles:
    INCBIN "res/battleship/ship-obp0.obj.2bpp"
    INCBIN "res/battleship/ship-obp1.obj.2bpp"
    ; Remove the first 2 tiles which are blank on purpose to get rid of
    ; any blank objects in the image
    INCBIN "res/battleship/boat.obj.2bpp", 16 * 2
    INCBIN "res/battleship/boat-motor.obj.2bpp"
    INCBIN "res/battleship/projectile.obj.2bpp"
    INCBIN "res/battleship/small-explosion.obj.2bpp"
.end

xMap1:
    INCBIN "res/battleship/background.bg.tilemap", 0, BATTLESHIP_OCEAN_SIZE * SCRN_X_B
.end
xMap2:
    INCBIN "res/battleship/background.bg.tilemap", BATTLESHIP_OCEAN_SIZE * SCRN_X_B
.end

xActorShipCannonDefinition:
    DB ACTOR_SHIP_CANNON
    DB BATTLESHIP_CANNON_X, BATTLESHIP_CANNON_Y
    DB 0, 0
.end
xActorShipDefinition:
    DB ACTOR_SHIP
    DB BATTLESHIP_SHIP_X, BATTLESHIP_SHIP_Y
    DB 0, 0

SECTION "Battleship Game Loop", ROMX

xGameBattleship::
    rst     WaitVBlank
    
    ; Check if currently transitioning to another screen
    ldh     a, [hTransitionState]
    ASSERT TRANSITION_STATE_OFF == 0
    and     a, a
    jr      z, .noTransition
    
    call    TransitionUpdate
    
    ; Check if the transition just ended
    ldh     a, [hTransitionState]
    ASSERT TRANSITION_STATE_OFF == 0
    and     a, a
    jr      nz, xGameBattleship
    
    ; Start music
    ld      c, BANK(Inst_Battleship)
    ld      de, Inst_Battleship
    call    Music_PrepareInst
    ld      c, BANK(Music_Battleship)
    ld      de, Music_Battleship
    call    Music_Play
    jr      xGameBattleship

.noTransition
    ; All directions perform the same action -> combine them into the
    ; Left bit
    ldh     a, [hNewKeys]
    ld      b, a
    and     a, PADF_RIGHT | PADF_UP | PADF_DOWN
    jr      z, .noChange
    ld      a, b
    and     a, LOW(~(PADF_RIGHT | PADF_UP | PADF_DOWN))
    set     PADB_LEFT, a
    ldh     [hNewKeys], a
.noChange
    
    call    EngineUpdate
    call    ActorsUpdate
    
    ld      a, [wMusicSyncData]
    ASSERT SYNC_NONE == -1
    inc     a
    jr      z, .noBoat
    dec     a   ; Undo inc
    ASSERT BATTLESHIP_BOATB_LEFT == 0
    rra     ; Move bit 0 into carry
    call    c, .boatLeft
    ld      a, [wMusicSyncData]
    bit     BATTLESHIP_BOATB_RIGHT, a
    call    nz, .boatRight
.noBoat
    
    ; Check for shooting the cannon
    ldh     a, [hNewKeys]
    bit     PADB_LEFT, a
    jr      nz, .shootLeft
.retShootLeft
    ASSERT PADB_A == 0
    rra     ; Move bit 0 into carry
    jr      c, .shootRight
.retShootRight
    
    ; Scroll the background
    ld      hl, hSCY
    dec     [hl]
    jr      nz, .noReset
    ld      [hl], BATTLESHIP_INITIAL_Y
.noReset
    ; Update the background (ocean waves) every 16 frames
    ldh     a, [hFrameCounter]
    and     a, 15
    jr      nz, xGameBattleship
    ; Toggle the background tilemap
    ldh     a, [hLCDC]
    xor     a, LCDCF_BG9800 ^ LCDCF_BG9C00
    ldh     [hLCDC], a
    jr      xGameBattleship

.boatLeft
    ASSERT BANK(xActorBoatLeftDefinition) == BANK(@)
    ld      de, xActorBoatLeftDefinition
    jp      ActorNew
    ASSERT CEL_BOAT_LEFT == 0
    ; No need to modify cel
.boatRight
    ASSERT BANK(xActorBoatRightDefinition) == BANK(@)
    ld      de, xActorBoatRightDefinition
    call    ActorNew
    ; Use right-turning animation
    ld      hl, wActorCelTable
    add     hl, bc
    ld      [hl], CEL_BOAT_RIGHT
    ret

.shootLeft
    ASSERT BANK(xActorProjectileLeftDefinition) == BANK(@)
    ld      de, xActorProjectileLeftDefinition
    call    ActorNew
    ASSERT CEL_BOAT_LEFT == 0
    ; No need to modify cel
    
    ; Restore A with hNewKeys for checking shoot right
    ldh     a, [hNewKeys]
    jr      .retShootLeft
.shootRight
    ASSERT BANK(xActorProjectileRightDefinition) == BANK(@)
    ld      de, xActorProjectileRightDefinition
    call    ActorNew
    ld      hl, wActorCelTable
    add     hl, bc
    ld      [hl], CEL_PROJECTILE_RIGHT
    
    jr      .retShootRight

xActorBoatLeftDefinition:
    DB ACTOR_BOAT_LEFT
    DB BOAT_LEFT_X, BOAT_Y
    DB BOAT_SPEED_X, BOAT_SPEED_Y
xActorBoatRightDefinition:
    DB ACTOR_BOAT_RIGHT
    DB BOAT_RIGHT_X, BOAT_Y
    DB BOAT_SPEED_X, BOAT_SPEED_Y

xActorProjectileLeftDefinition:
    DB ACTOR_PROJECTILE
    DB PROJECTILE_X, PROJECTILE_Y
    DB PROJECTILE_LEFT_SPEED_X, PROJECTILE_SPEED_Y
xActorProjectileRightDefinition:
    DB ACTOR_PROJECTILE
    DB PROJECTILE_X, PROJECTILE_Y
    DB PROJECTILE_RIGHT_SPEED_X, PROJECTILE_SPEED_Y

SECTION "Battleship Left Boat Actor", ROMX

xActorBoatLeft::
    ; Kill if shot
    ldh     a, [hNewKeys]
    bit     PADB_LEFT, a
    ret     z
    
    ; Manually kill before creating new actors
    ld      hl, wActorTypeTable
    add     hl, bc
    ld      [hl], ACTOR_EMPTY
    ; Create explosion
    ASSERT BANK(xActorSmallExplosionLeft1Definition) == BANK(@)
    ld      de, xActorSmallExplosionLeft1Definition
    call    ActorNew
    ASSERT BANK(xActorSmallExplosionLeft2Definition) == BANK(@)
    ld      de, xActorSmallExplosionLeft2Definition
    call    ActorNew
    ; Skip update
    pop     af
    jp      ActorsUpdate.next

xActorSmallExplosionLeft1Definition:
    DB ACTOR_SMALL_EXPLOSION
    DB EXPLOSION_LEFT_X, EXPLOSION_Y
    DB 0, 0
xActorSmallExplosionLeft2Definition:
    DB ACTOR_SMALL_EXPLOSION
    DB EXPLOSION_LEFT_X + 8, EXPLOSION_Y + 8
    DB 0, 0

SECTION "Battleship Right Boat Actor", ROMX

xActorBoatRight::
    ; Kill if shot
    ldh     a, [hNewKeys]
    bit     PADB_A, a
    ret     z
    
    ; Manually kill before creating new actors
    ld      hl, wActorTypeTable
    add     hl, bc
    ld      [hl], ACTOR_EMPTY
    ; Create explosion
    ASSERT BANK(xActorSmallExplosionRight1Definition) == BANK(@)
    ld      de, xActorSmallExplosionRight1Definition
    call    ActorNew
    ASSERT BANK(xActorSmallExplosionRight2Definition) == BANK(@)
    ld      de, xActorSmallExplosionRight2Definition
    call    ActorNew
    ; Skip update
    pop     af
    jp      ActorsUpdate.next

xActorSmallExplosionRight1Definition:
    DB ACTOR_SMALL_EXPLOSION
    DB EXPLOSION_RIGHT_X, EXPLOSION_Y
    DB 0, 0
xActorSmallExplosionRight2Definition:
    DB ACTOR_SMALL_EXPLOSION
    DB EXPLOSION_RIGHT_X + 8, EXPLOSION_Y + 8
    DB 0, 0
