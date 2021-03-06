INCLUDE "constants/hardware.inc"
INCLUDE "constants/actors.inc"
INCLUDE "constants/screens.inc"
INCLUDE "constants/games/skater-dude.inc"

SECTION "Actor Rendering Temporary Variables", HRAM

hActorYPos:
    DS 1
hActorXPos:
    DS 1

SECTION "Per-Game Actor Tile Streaming Enable", HRAM

; Whether or not the current game's actors use tile streaming
; 0 to disable tile streaming (the game and its actors must handle tiles
; themselves), non-zero to enable tile streaming (actors' tile numbers
; adjusted automatically)
hTileStreamingEnable::
    DS 1

SECTION "Actor Type Table", WRAM0

; Type of actor, ACTOR_EMPTY for empty
wActorTypeTable::
    DS MAX_ACTOR_COUNT

SECTION "Actor Position Tables", WRAM0

; 8-bit positions, relative to the screen

wActorXPosTable::
    DS MAX_ACTOR_COUNT
wActorYPosTable::
    DS MAX_ACTOR_COUNT

SECTION "Actor Speed Tables", WRAM0

; Q5.3 fixed point speeds
; Fractional part added to fractional accumulator, integer part and
; fractional accumulator carry added to position

wActorXSpeedTable::
    DS MAX_ACTOR_COUNT
wActorYSpeedTable::
    DS MAX_ACTOR_COUNT

SECTION "Actor Speed Fractional Accumulator Tables", WRAM0

; Accumulator of speeds' fractional parts
; The carries from here are added along with the integer part of the
; speed to the actor's position

wActorXSpeedAccTable::
    DS MAX_ACTOR_COUNT
wActorYSpeedAccTable::
    DS MAX_ACTOR_COUNT

SECTION "Actor Animation Cel Tables", WRAM0

; Index of the current animation cel, used to find meta-sprite data in
; the actor's type's animation table
wActorCelTable::
    DS MAX_ACTOR_COUNT

; A value other than ANIMATION_OVERRIDE_NONE here means an animation override
; is in effect, and that value will be used instead of the main
; animation's current cel number
; The main animation will continue to be updated as normal: animation
; overrides are used to keep the main animation in sync with the music
; while another animation plays temporarily
wActorCelOverrideTable::
    DS MAX_ACTOR_COUNT

SECTION "Actor Animation Cel Countdown Tables", WRAM0

; Number of frames left until the next animation cel
wActorCelCountdownTable::
    DS MAX_ACTOR_COUNT

; Ditto, but for the override animation
wActorCelOverrideCountdownTable::
    DS MAX_ACTOR_COUNT

SECTION "Actor Tile Copy Buffer", WRAM0

; Tile data to be copied to VRAM during VBlank to avoid prematurely
; using new tiles
wActorTileBuffer::
    DS ACTOR_RESERVED_TILE_COUNT * 16

SECTION "Actor New Tiles Variables", HRAM

; Half the number of bytes to copy from wActorTileBuffer to VRAM for the
; VBlank interrupt handler, -1 for none
hActorNewTileLength::
    DS 1

; Actor index of the actor using wActorTileBuffer, so that the same one
; can overwrite it
hNewTileActorIndex:
    DS 1

; Desination of new tile data for the VBlank interrupt handler
hActorTileDest::
.low
    DS 1
.high
    DS 1

SECTION "Actor Update", ROM0

ActorsUpdate::
    ; Save current bank to restore when finished
    ldh     a, [hCurrentBank]
    push    af
    
    xor     a, a
    ldh     [hNextOAMSlot], a
    ld      bc, 0   ; bc = actor index
.loop
    ld      hl, wActorTypeTable
    add     hl, bc
    ; If actor type is ACTOR_EMPTY, skip this actor
    ld      a, [hl]
    ASSERT ACTOR_EMPTY == -1
    inc     a
    jr      nz, .update
    
.next::
    ; Move to the next actor
    ASSERT HIGH(MAX_ACTOR_COUNT) == 0
    inc     c
    ld      a, c
    cp      a, MAX_ACTOR_COUNT
    jr      c, .loop
    
    ; Restore bank
    pop     af
    ldh     [hCurrentBank], a
    ld      [rROMB0], a
    
    jp      HideUnusedObjects

.update
    ; Save this actor's type * 3 for quick access
    dec     a       ; Undo inc
    add     a, a    ; a * 2 (Pointer)
    add     a, [hl] ; a * 3 (+Bank)
    ldh     [hScratch1], a
    
    ; Update actor's regular animation
    call    ActorUpdateAnimation
    
    ; Check for override animation
    ld      hl, wActorCelOverrideTable
    add     hl, bc
    ld      a, [hl]
    ASSERT ANIMATION_OVERRIDE_NONE == -1
    inc     a
    jr      z, .updatePosition
    
    ; Check for slo-mo
    ; Don't update the override animation during slo-mo
    ldh     a, [hCurrentScreen]
    cp      a, GAME_SKATER_DUDE
    jr      nz, .updateOverrideAnimation
    ldh     a, [hSloMoCountdown]
    ; No slo-mo is non-zero in the update bits, adjust for that
    ASSERT SKATER_DUDE_NO_SLO_MO + 1 & SKATER_DUDE_SLO_MO_UPDATE_MASK == 0
    inc     a
    and     a, SKATER_DUDE_SLO_MO_UPDATE_MASK
    jr      nz, .updatePosition
.updateOverrideAnimation
    ; Update actor's override animation
    ASSERT wActorCelOverrideTable == wActorCelTable + MAX_ACTOR_COUNT
    ASSERT wActorCelOverrideCountdownTable == wActorCelCountdownTable + MAX_ACTOR_COUNT
    ; Override animation tables directly follow the regular animation
    ; tables, so MAX_ACTOR_COUNT (the tables' sizes) can simply be added
    ; to the entity index in bc
    push    bc
    ASSERT HIGH(MAX_ACTOR_COUNT * 2) == HIGH(MAX_ACTOR_COUNT)
    ld      a, c
    add     a, MAX_ACTOR_COUNT
    ld      c, a
    call    ActorUpdateAnimation
    pop     bc
    
.updatePosition
    ; Update the actor's position
    ; X position
    call    ActorAddSpeedToPos
    ; Y position
    ASSERT wActorYSpeedTable == wActorXSpeedTable + MAX_ACTOR_COUNT
    ASSERT wActorYSpeedAccTable == wActorXSpeedAccTable + MAX_ACTOR_COUNT
    ; Y speed tables directly follow the X speed tables, so
    ; MAX_ACTOR_COUNT (the tables' sizes) can simply be added to the
    ; entity index in bc
    push    bc
    ASSERT HIGH(MAX_ACTOR_COUNT * 2) == HIGH(MAX_ACTOR_COUNT)
    ld      a, c
    add     a, MAX_ACTOR_COUNT
    ld      c, a
    call    ActorAddSpeedToPos
    pop     bc
    
.skipPositionUpdate
    ; Call the actor's update routine
    ldh     a, [hScratch1]  ; a = actor type
    add     a, LOW(ActorRoutineTable)
    ld      l, a
    ASSERT HIGH(ActorRoutineTable.end - 1) == HIGH(ActorRoutineTable)
    ld      h, HIGH(ActorRoutineTable)
    
    ld      a, [hli]
    and     a, a
    ; If the bank number is 0, the actor has no update routine
    jr      z, .noUpdate
    ldh     [hCurrentBank], a
    ld      [rROMB0], a
    ld      a, [hli]
    ld      h, [hl]
    ld      l, a
    rst     JP_HL
.noUpdate
    
    ; Render this actor
    
    ; Save actor's Y position for use in meta-sprites
    ld      hl, wActorYPosTable
    add     hl, bc
    ld      a, [hl]
    ; Y position offset (+16) already applied in meta-sprite data
    ldh     [hActorYPos], a
    
    ; Save actor's X position for use in meta-sprites
    ld      hl, wActorXPosTable
    add     hl, bc
    ld      a, [hl]
    ; X position offset (OAM_X_OFS) already applied in meta-sprite data
    ldh     [hActorXPos], a
    
    ; Use actor's override animation cel if an animation override is in
    ; effect
    ld      hl, wActorCelOverrideTable
    add     hl, bc
    ld      a, [hl]
    ASSERT ANIMATION_OVERRIDE_NONE == -1
    inc     a
    jr      nz, .override
    
    ; No animation override -> get regular animation cel
    call    ActorGetAnimationCel
    jr      .render
.override
    ; Animation override -> get animation override cel
    ASSERT wActorCelOverrideTable == wActorCelTable + MAX_ACTOR_COUNT
    ASSERT wActorCelOverrideCountdownTable == wActorCelCountdownTable + MAX_ACTOR_COUNT
    push    bc
    ASSERT HIGH(MAX_ACTOR_COUNT * 2) == HIGH(MAX_ACTOR_COUNT)
    ld      a, c
    add     a, MAX_ACTOR_COUNT
    ld      c, a
    call    ActorGetAnimationCel
    pop     bc
.render
    ld      a, [hl]     ; a = meta-sprite number
    add     a, a        ; a * 2 (Pointer)
    ld      e, a        ; Save in e
    
    ; Find meta-sprite table
    ldh     a, [hScratch1]  ; a = actor type
    add     a, LOW(ActorMetaspriteTable)
    ld      l, a
    ASSERT HIGH(ActorMetaspriteTable.end - 1) == HIGH(ActorMetaspriteTable)
    ld      h, HIGH(ActorMetaspriteTable)
    
    ; Point hl to actor's type's meta-sprite table
    ld      a, [hli]
    ld      [rROMB0], a
    ld      a, [hli]
    ld      h, [hl]
    add     a, e
    ld      l, a
    adc     a, h
    sub     a, l
    ld      h, a
    
    ; Point hl to meta-sprite data
    ld      a, [hli]
    ld      h, [hl]
    ld      l, a
    
    ; Point de to next OAM slot
    ldh     a, [hNextOAMSlot]
    ; If there aren't any free slots, give up
    cp      a, OAM_COUNT
    jp      nc, .next
    add     a, a
    add     a, a
    ld      e, a
    ld      d, HIGH(wShadowOAM)
    
    push    bc
    ldh     a, [hTileStreamingEnable]
    and     a, a
    jr      z, .noTileStreaming
    
    ; Get first tile number of this actor's reserved tiles
    ASSERT HIGH(MAX_ACTOR_COUNT) == 0
    ; Can just use c since b is always 0
    ASSERT ACTOR_RESERVED_TILE_COUNT == 16
    swap    c       ; actor index * 16
    ASSERT MAX_ACTOR_COUNT & ~$0F == 0
    ; No need to clear low nibble (already 0)
    ; Carry cleared from swap
    DB      $38     ; jr c, e8 to consume the next byte
.noTileStreaming
    ; a = 0
    ld      c, a
.metaspriteLoop
    ; Check for end-of-data special value
    ld      a, [hl]
    cp      a, METASPRITE_END
    jr      z, .metaspriteEnd
    
    ; Y position
    ldh     a, [hActorYPos]
    add     a, [hl]
    inc     hl
    ld      [de], a
    inc     e
    
    ; X position
    ldh     a, [hActorXPos]
    add     a, [hl]
    inc     hl
    ld      [de], a
    inc     e
    
    ; Tile number
    ld      a, [hli]
    add     a, c    ; c = reserved actor tiles start OR 0
    ld      [de], a
    inc     e
    
    ; Attributes
    ld      a, [hli]
    ld      [de], a
    inc     e
    
    ; Just took up 1 OAM slot
    ldh     a, [hNextOAMSlot]
    inc     a
    ; If used up all OAM slots, give up
    cp      a, OAM_COUNT
    jr      nc, .metaspriteEnd
    ldh     [hNextOAMSlot], a
    jr      .metaspriteLoop

.metaspriteEnd
    ; Get back the actor index
    pop     bc
    ; Move to next actor
    jp      .next

SECTION "Actor Creation", ROM0

; Create a new actor
; @param    de  Pointer to actor definition
; @return   bc  Actor index
ActorNew::
    ld      hl, wActorTypeTable
    ld      bc, 0   ; bc = actor index
.loop
    ; If actor type is ACTOR_EMPTY, use this slot
    ld      a, [hl]
    ASSERT ACTOR_EMPTY == -1
    inc     a
    jr      z, .foundEmptySlot
    
    ; Move to the next slot
    inc     hl
    ASSERT HIGH(MAX_ACTOR_COUNT) == 0
    inc     c
    ld      a, c
    ; If gone through all actors, return
    cp      a, MAX_ACTOR_COUNT
    jr      c, .loop
    ret

.foundEmptySlot
    ; Set actor type
    ld      a, [de]
    inc     de
    ld      [hl], a
    
    ; Reset cel number
    ld      hl, wActorCelTable
    add     hl, bc
    ld      [hl], 0
    
    ; Set actor animation cel countdown
    ld      l, a
    add     a, a    ; a * 2 (Pointer)
    add     a, l    ; a * 3 (+Bank)
    add     a, LOW(ActorAnimationTable)
    ld      l, a
    ASSERT WARN, HIGH(ActorAnimationTable.end - 1) != HIGH(ActorAnimationTable)
    adc     a, HIGH(ActorAnimationTable)
    sub     a, l
    ld      h, a
    
    ; Save current bank to restore when finished
    ldh     a, [hCurrentBank]
    push    af
    
    ld      a, [hli]
    ld      [rROMB0], a
    ld      a, [hli]
    ld      h, [hl]
    ld      l, a
    ; Set up the first animation cel
    ld      a, [hli]
    ; Check if the first item is the set tiles command
    cp      a, ANIMATION_SET_TILES
    jr      nz, .setDuration
    
    ; First copy tiles
    push    hl
    push    de
    call    ActorSetTiles
    ; Update cel number to skip the command (4 bytes)
    ld      hl, wActorCelTable
    add     hl, bc
    ld      [hl], 0 + 2 ; Cel number was set to 0 above
    pop     de
    pop     hl
    ; Skip over tile pointer + byte count + next meta-sprite number
    ld      a, l
    add     a, 4
    ld      l, a
    ld      a, h
    ASSERT HIGH(MAX_ACTOR_COUNT) == 0
    adc     a, b    ; b = 0
    ld      h, a
.setDuration
    ; Use first animation cel's duration
    ld      a, [hl] ; a = cel duration
    ld      hl, wActorCelCountdownTable
    add     hl, bc
    ld      [hl], a
    
    ; Restore bank
    pop     af
    ldh     [hCurrentBank], a
    ld      [rROMB0], a
    
    ; Set actor position
    ld      hl, wActorXPosTable
    add     hl, bc
    ld      a, [de]
    inc     de
    ld      [hl], a
    ld      hl, wActorYPosTable
    add     hl, bc
    ld      a, [de]
    inc     de
    ld      [hl], a
    
    ; Set actor speed
    ld      hl, wActorXSpeedTable
    add     hl, bc
    ld      a, [de]
    inc     de
    ld      [hl], a
    ld      hl, wActorYSpeedTable
    add     hl, bc
    ld      a, [de]
    inc     de
    ld      [hl], a
    
    ; Reset actor animation override
    ld      hl, wActorCelOverrideTable
    add     hl, bc
    ld      [hl], ANIMATION_OVERRIDE_NONE
    
    ret

SECTION "Actor Add Speed to Position", ROM0

; Add an actor's speed to its position on a single axis
; @param    bc  Actor index
ActorAddSpeedToPos:
    ; Get actor speed value
    ld      hl, wActorXSpeedTable
    add     hl, bc
    ld      a, [hl]
    swap    a
    ld      e, a    ; Save speed temporarily in e
    
    ; Get fractional part (high 3 bits)
    add     a, a    ; Shift left
    and     a, $E0
    ; Add fractional part to fractional accumulator
    ld      hl, wActorXSpeedAccTable
    add     hl, bc
    add     a, [hl]
    ld      [hl], a
    
    ld      a, e    ; Restore speed from e
    rr      e       ; Save carry from fractional part in e
    ; Get integer part (low 5 bits)
    rlca
    and     a, $1F
    ; If the speed is negative, sign extend the integer part
    ; Don't need to do this with the fractional part since it will still
    ; produce a carry at the correct rate
    bit     4, a    ; Sign in bit 4
    jr      z, .positive
    or      a, $E0  ; Sign extend
.positive
    ld      hl, wActorXPosTable
    add     hl, bc
    rl      e       ; Restore carry from fractional part
    adc     a, [hl] ; Add integer part + fractional part carry to position
    ld      [hl], a
    
    ret

SECTION "Actor Animation Update", ROM0

; Update an actor's animation cel countdown and update its cel number as
; well if necessary
; @param    bc  Actor index
ActorUpdateAnimation:
    ; Update actor's animation cel countdown
    ld      hl, wActorCelCountdownTable
    add     hl, bc
    ; If the cel lasts forever, don't do anything
    ld      a, [hl]
    ASSERT ANIMATION_DURATION_FOREVER == -1
    inc     a
    ret     z
    
    ; Decrement countdown
    dec     [hl]
    ; If not reached 0 yet, there's nothing to do
    ret     nz
    
    ; Animation cel countdown reached 0, increment animation cel number
    ld      hl, wActorCelTable
    add     hl, bc
    inc     [hl]
    
.advanceAnimation
    call    ActorGetAnimationCel
    ; Check if this is a command (bit 7 set)
    bit     7, [hl]
    jr      nz, .command
.setCountdown
    inc     hl      ; Get duration
    ld      a, [hl] ; a = cel duration
    ld      hl, wActorCelCountdownTable
    add     hl, bc
    ld      [hl], a
    ret

.command
    ; Figure out which command this is
    ld      a, [hli]
    and     a, LOW(~$80)
    ASSERT ANIMATION_GOTO & ~$80 == 0
    jr      z, .goto
    ASSERT ANIMATION_KILL_ACTOR & ~$80 == 1
    dec     a
    ; Kill this actor
    ; WARNING: This will break if the kill actor command is encountered
    ; in an animation override, since bc isn't actually correct!
    jp      z, ActorKill
    ASSERT ANIMATION_OVERRIDE_END & ~$80 == 2
    dec     a
    jr      z, .overrideEnd
    ASSERT ANIMATION_SET_TILES & ~$80 == 3
    ASSERT ANIMATION_SPECIAL_VALUE_COUNT == 4
    
    ; Stream a set of tiles to VRAM
    call    ActorSetTiles
    ; Update cel number to skip the command (4 bytes)
    ld      hl, wActorCelTable
    add     hl, bc
    inc     [hl]    ; Command + HIGH(Tile pointer)
    inc     [hl]    ; LOW(Tile pointer) + length
    jr      .advanceAnimation

.overrideEnd
    ; Animation override end
    ; WARNING: This will break if the animation override end command is
    ; encountered outside of an animation override, since this code
    ; assumes bc has the animation override offset!
    push    hl
    ld      hl, wActorCelTable
    add     hl, bc
    ; hl should now point to the actor's spot in wActorCelOverrideTable
    ld      [hl], ANIMATION_OVERRIDE_NONE
    pop     hl
    
    ; Get cel number to reset to
    ld      a, [hl]
    ASSERT ANIMATION_OVERRIDE_END_NO_TILES == -1
    inc     a
    ret     z
    
    ; Copy tiles
    ; WARNING: This will break if the given reset cel does not point to
    ; a set tiles command!
    dec     a   ; Undo inc
    add     a, a    ; a * 2 (Meta-sprite + Duration)
    inc     a       ; Skip set tiles command byte
    add     a, e
    ld      l, a
    adc     a, d
    sub     a, l
    ld      h, a
    ; Fix actor index
    ASSERT HIGH(MAX_ACTOR_COUNT) == 0
    ld      a, c
    sub     a, MAX_ACTOR_COUNT
    ld      c, a
    jp      ActorSetTiles

.goto
    ; Goto: Jump to another position in the animation
    ld      a, [hl] ; a = new cel number
    ld      hl, wActorCelTable
    add     hl, bc
    ld      [hl], a
    jr      .advanceAnimation

SECTION "Actor Kill", ROM0

; @param    bc  Actor index
ActorKill::
    ld      hl, wActorTypeTable
    add     hl, bc
    ld      [hl], ACTOR_EMPTY
    ; Don't update because the actor is now gone
    pop     af      ; Skip return to ActorsUpdate
    jp      ActorsUpdate.next

SECTION "Actor Tile Streaming", ROM0

; Copy tiles to an actor's reserved tiles in VRAM
; @param    hl  Pointer to 2nd byte of set tiles command
; @param    bc  Actor index
ActorSetTiles:
    push    bc
    ; Check if the actor index is wrong (for override animations)
    ld      a, c
    cp      a, MAX_ACTOR_COUNT
    jr      c, .indexOk
    ; Fix actor index
    ASSERT HIGH(MAX_ACTOR_COUNT) == 0
    sub     a, MAX_ACTOR_COUNT
    ld      c, a
.indexOk
    ; Get the pointer to the tile data
    ld      a, [hli]
    ld      e, a
    ld      a, [hli]
    ld      d, a
    ASSERT HIGH(MAX_ACTOR_COUNT) == 0
    ; Save number of bytes (halved for copy loop unroll)
    ld      b, [hl]
    
    ; Get the pointer to the destination in VRAM
    ASSERT HIGH(MAX_ACTOR_COUNT) == 0
    ld      a, c
    swap    a       ; actor index * 16
    ASSERT MAX_ACTOR_COUNT & ~$0F == 0
    ; No need to clear low nibble (already 0)
    ASSERT WARN, HIGH(MAX_ACTOR_COUNT * 16 * 2) != 0
    ; High byte won't be 0 after the next x2 -> move to hl
    ld      l, a
    ld      h, HIGH($8000 >> 4)
    ASSERT ACTOR_RESERVED_TILE_COUNT == 16
    add     hl, hl  ; actor index * 2
    add     hl, hl  ; actor index * 4
    add     hl, hl  ; actor index * 8
    add     hl, hl  ; actor index * 16
    
    ; If another actor is already using the tile buffer, copy directly
    ; to VRAM
    ldh     a, [hActorNewTileLength]
    inc     a
    jr      z, .useBuffer
    ; If the actor using it is this actor, overwrite the buffer
    ldh     a, [hNewTileActorIndex]
    cp      a, c
    jr      nz, .copyVRAMLoop
.useBuffer
    ; Save the destination address and data size for the VBlank
    ; interrupt handler
    ld      a, l
    ldh     [hActorTileDest.low], a
    ld      a, h
    ldh     [hActorTileDest.high], a
    ld      a, b
    ldh     [hActorNewTileLength], a
    ld      a, c
    ldh     [hNewTileActorIndex], a
    
    ; Copy tile data to copy buffer to be written to VRAM during VBlank
    ld      hl, wActorTileBuffer
.copyLoop
    ld      a, [de]
    ld      [hli], a
    inc     de
    ld      a, [de]
    ld      [hli], a
    inc     de
    dec     b
    jr      nz, .copyLoop
    
    pop     bc
    ret

    ; Copy the tiles to VRAM
    ; de = source
    ; hl = destination
    ; b = length / 2
.copyVRAMLoop
    ldh     a, [rSTAT]
    and     a, STATF_BUSY
    jr      nz, .copyVRAMLoop
    
    ld      a, [de]     ; 2 cycles
    ld      [hli], a    ; 2 cycles
    inc     de          ; 2 cycles
    ld      a, [de]     ; 2 cycles
    ld      [hli], a    ; 2 cycles
    ; Total 10 cycles
    ; Can't copy 3 bytes at a time because the byte count won't always
    ; be divisible by 3
    inc     de
    dec     b
    jr      nz, .copyVRAMLoop
    
    pop     bc
    ret

SECTION "Actor Get Animation Table", ROM0

; Point hl to the current cel in the current actor's animation table
; @param    bc          Actor index
; @param    [hScratch1] Actor type * 3
; @return   hl          Pointer to current animation cel data
; @return   de          Pointer to animation table
ActorGetAnimationCel:
    ; Find animation table
    ldh     a, [hScratch1]  ; a = actor type * 3
    add     a, LOW(ActorAnimationTable)
    ld      l, a
    ASSERT WARN, HIGH(ActorAnimationTable.end - 1) != HIGH(ActorAnimationTable)
    adc     a, HIGH(ActorAnimationTable)
    sub     a, l
    ld      h, a
    
    ; Point hl to actor's type's animation table
    ld      a, [hli]
    ld      [rROMB0], a
    ld      a, [hli]
    ld      d, [hl]
    ld      e, a
    
    ; Get actor's current cel
    ld      hl, wActorCelTable
    add     hl, bc
    ld      a, [hl] ; a = cel number
    ; Get current cel
    add     a, a    ; a * 2 (Meta-sprite + Duration)
    add     a, e
    ld      l, a
    adc     a, d
    sub     a, l
    ld      h, a
    
    ret

SECTION "Actor Set Animation Cel", ROM0

; Set an actor's current cel and set the cel countdown to its starting
; value
; @param    a           Cel number
; @param    bc          Actor index
; @param    [hScratch1] Actor type * 3
; @return   hl          Pointer to current animation cel data
; @return   de          Pointer to animation table
ActorSetCel::
    ; Set new cel number
    ld      hl, wActorCelTable
    add     hl, bc
    ld      [hl], a
    ; Save new cel number for later reference
    ldh     [hScratch2], a
    
    ; Save current bank to restore when finished
    ldh     a, [hCurrentBank]
    push    af
    
    ; Find animation table
    ldh     a, [hScratch1]  ; a = actor type * 3
    add     a, LOW(ActorAnimationTable)
    ld      l, a
    ASSERT WARN, HIGH(ActorAnimationTable.end - 1) != HIGH(ActorAnimationTable)
    adc     a, HIGH(ActorAnimationTable)
    sub     a, l
    ld      h, a
    
    ; Point hl to actor's type's animation table
    ld      a, [hli]
    ld      [rROMB0], a
    ld      a, [hli]
    ld      d, [hl]
    ld      e, a
    
    ; Get actor's current cel
    ldh     a, [hScratch2]
    ; Get current cel's duration
    add     a, a    ; a * 2 (Meta-sprite + Duration)
    add     a, e
    ld      l, a
    adc     a, d
    sub     a, l
    ld      h, a
    ; Take care of any commands and set the cel duration
    call    ActorUpdateAnimation.advanceAnimation
    
    ; Restore bank
    pop     af
    ldh     [hCurrentBank], a
    ld      [rROMB0], a
    ret

SECTION "Actor Set Animation Override Cel", ROM0

; Set an actor's animation override cel and set the override cel
; countdown to its starting value
; @param    a           Cel number
; @param    bc          Actor index
; @param    [hScratch1] Actor type * 3
; @return   hl          Pointer to current animation cel data
; @return   de          Pointer to animation table
ActorSetAnimationOverride::
    ASSERT wActorCelOverrideTable == wActorCelTable + MAX_ACTOR_COUNT
    ASSERT wActorCelOverrideCountdownTable == wActorCelCountdownTable + MAX_ACTOR_COUNT
    push    bc
    ld      b, a    ; Save cel number
    ASSERT HIGH(MAX_ACTOR_COUNT * 2) == HIGH(MAX_ACTOR_COUNT)
    ld      a, c
    add     a, MAX_ACTOR_COUNT
    ld      c, a
    ld      a, b    ; Restore cel number
    ld      b, 0
    call    ActorSetCel
    pop     bc
    ret
