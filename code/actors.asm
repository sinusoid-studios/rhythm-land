INCLUDE "constants/hardware.inc"
INCLUDE "constants/actors.inc"
INCLUDE "constants/games.inc"
INCLUDE "constants/games/skater-dude.inc"

SECTION "Actor Rendering Temporary Variables", HRAM

hActorYPos:
    DS 1
hActorXPos:
    DS 1

SECTION "Actor Type Table", WRAM0

; Type of actor, ACTOR_EMPTY for empty
wActorTypeTable::
    DS MAX_NUM_ACTORS

SECTION "Actor Position Tables", WRAM0

; 8-bit positions, relative to the screen

wActorXPosTable::
    DS MAX_NUM_ACTORS
wActorYPosTable::
    DS MAX_NUM_ACTORS

SECTION "Actor Speed Tables", WRAM0

; Q5.3 fixed point speeds
; Fractional part added to fractional accumulator, integer part and
; fractional accumulator carry added to position

wActorXSpeedTable::
    DS MAX_NUM_ACTORS
wActorYSpeedTable::
    DS MAX_NUM_ACTORS

SECTION "Actor Speed Fractional Accumulator Tables", WRAM0

; Accumulator of speeds' fractional parts
; The carries from here are added along with the integer part of the
; speed to the actor's position

wActorXSpeedAccTable::
    DS MAX_NUM_ACTORS
wActorYSpeedAccTable::
    DS MAX_NUM_ACTORS

SECTION "Actor Animation Cel Tables", WRAM0

; Index of the current animation cel, used to find meta-sprite data in
; the actor's type's animation table
wActorCelTable::
    DS MAX_NUM_ACTORS

; A value other than ANIMATION_OVERRIDE_NONE here means an animation override
; is in effect, and that value will be used instead of the main
; animation's current cel number
; The main animation will continue to be updated as normal: animation
; overrides are used to keep the main animation in sync with the music
; while another animation plays temporarily
wActorCelOverrideTable::
    DS MAX_NUM_ACTORS

SECTION "Actor Animation Cel Countdown Tables", WRAM0

; Number of frames left until the next animation cel
wActorCelCountdownTable::
    DS MAX_NUM_ACTORS

; Ditto, but for the override animation
wActorCelOverrideCountdownTable::
    DS MAX_NUM_ACTORS

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
    
.next
    ; Move to the next actor
    ASSERT HIGH(MAX_NUM_ACTORS) == 0
    inc     c
    ld      a, c
    cp      a, MAX_NUM_ACTORS
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
    call    ActorsUpdateAnimation
    
    ; Check for override animation
    ld      hl, wActorCelOverrideTable
    add     hl, bc
    ld      a, [hl]
    ASSERT ANIMATION_OVERRIDE_NONE == -1
    inc     a
    jr      z, .updatePosition
    
    ; Check for slo-mo
    ; Don't update the override animation during slo-mo
    ldh     a, [hCurrentGame]
    cp      a, ID_SKATER_DUDE
    jr      nz, .updateOverrideAnimation
    ldh     a, [hSloMoCountdown]
    and     a, SKATER_DUDE_SLO_MO_UPDATE_MASK
    jr      nz, .updatePosition
.updateOverrideAnimation
    ; Update actor's override animation
    ASSERT wActorCelOverrideTable == wActorCelTable + MAX_NUM_ACTORS
    ASSERT wActorCelOverrideCountdownTable == wActorCelCountdownTable + MAX_NUM_ACTORS
    ; Override animation tables directly follow the regular animation
    ; tables, so MAX_NUM_ACTORS (the tables' sizes) can simply be added
    ; to the entity index in bc
    push    bc
    ASSERT HIGH(MAX_NUM_ACTORS * 2) == HIGH(MAX_NUM_ACTORS)
    ld      a, c
    add     a, MAX_NUM_ACTORS
    ld      c, a
    call    ActorsUpdateAnimation
    pop     bc
    
.updatePosition
    ldh     a, [hCurrentGame]
    cp      a, ID_SKATER_DUDE
    jp      z, .maybeSloMo
.noSloMo
    ; Update the actor's position
    ; X position
    call    ActorsAddSpeedToPos
    ; Y position
    ASSERT wActorYSpeedTable == wActorXSpeedTable + MAX_NUM_ACTORS
    ASSERT wActorYSpeedAccTable == wActorXSpeedAccTable + MAX_NUM_ACTORS
    ; Y speed tables directly follow the X speed tables, so
    ; MAX_NUM_ACTORS (the tables' sizes) can simply be added to the
    ; entity index in bc
    push    bc
    ASSERT HIGH(MAX_NUM_ACTORS * 2) == HIGH(MAX_NUM_ACTORS)
    ld      a, c
    add     a, MAX_NUM_ACTORS
    ld      c, a
    call    ActorsAddSpeedToPos
    pop     bc
    
.skipPositionUpdate
    ; Call the actor's update routine
    ldh     a, [hScratch1]  ; a = actor type
    add     a, LOW(ActorRoutineTable)
    ld      l, a
    ASSERT HIGH(ActorRoutineTable.end - 1) != HIGH(ActorRoutineTable)
    adc     a, HIGH(ActorRoutineTable)
    sub     a, l
    ld      h, a
    
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
    add     a, 16
    ldh     [hActorYPos], a
    
    ; Save actor's X position for use in meta-sprites
    ld      hl, wActorXPosTable
    add     hl, bc
    ld      a, [hl]
    add     a, 8
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
    call    ActorsGetAnimationCel
    jr      .render
.override
    ; Animation override -> get animation override cel
    ASSERT wActorCelOverrideTable == wActorCelTable + MAX_NUM_ACTORS
    ASSERT wActorCelOverrideCountdownTable == wActorCelCountdownTable + MAX_NUM_ACTORS
    push    bc
    ASSERT HIGH(MAX_NUM_ACTORS * 2) == HIGH(MAX_NUM_ACTORS)
    ld      a, c
    add     a, MAX_NUM_ACTORS
    ld      c, a
    call    ActorsGetAnimationCel
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
    ldh     [hCurrentBank], a
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
    add     a, a
    add     a, a
    ld      e, a
    ld      d, HIGH(wShadowOAM)
    
.metaspriteLoop
    ; Check for end-of-data special value
    ld      a, [hl]
    cp      a, METASPRITE_END
    jp      z, .next
    
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
    ld      [de], a
    inc     e
    
    ; Attributes
    ld      a, [hli]
    ld      [de], a
    inc     e
    
    ; Just took up 1 OAM slot
    ldh     a, [hNextOAMSlot]
    inc     a
    ldh     [hNextOAMSlot], a
    jr      .metaspriteLoop

.maybeSloMo
    ldh     a, [hSloMoCountdown]
    and     a, a
    jp      z, .noSloMo
    
    ; Divide speeds
    ASSERT SKATER_DUDE_SLO_MO_DIVIDE == 4
    ld      hl, wActorXSpeedTable
    add     hl, bc
    ld      a, [hl]
    ldh     [hScratch2], a
    sra     a       ; speed / 2
    sra     a       ; speed / 4
    ld      [hl], a
    ld      hl, wActorYSpeedTable
    add     hl, bc
    ld      a, [hl]
    ldh     [hScratch3], a
    sra     a       ; speed / 2
    sra     a       ; speed / 4
    ld      [hl], a
    
    ; Update the actor's position
    ; X position
    call    ActorsAddSpeedToPos
    ; Y position
    ASSERT wActorYSpeedTable == wActorXSpeedTable + MAX_NUM_ACTORS
    ASSERT wActorYSpeedAccTable == wActorXSpeedAccTable + MAX_NUM_ACTORS
    push    bc
    ASSERT HIGH(MAX_NUM_ACTORS * 2) == HIGH(MAX_NUM_ACTORS)
    ld      a, c
    add     a, MAX_NUM_ACTORS
    ld      c, a
    call    ActorsAddSpeedToPos
    pop     bc
    
    ld      hl, wActorXSpeedTable
    add     hl, bc
    ldh     a, [hScratch2]
    ld      [hl], a
    ld      hl, wActorYSpeedTable
    add     hl, bc
    ldh     a, [hScratch3]
    ld      [hl], a
    
    jp      .skipPositionUpdate

SECTION "Actor Creation", ROM0

; Create a new actor
; @param    de  Pointer to actor definition
; @return   bc  Actor index
ActorsNew::
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
    ASSERT HIGH(MAX_NUM_ACTORS) == 0
    inc     c
    ld      a, c
    ; If gone through all actors, return
    cp      a, MAX_NUM_ACTORS
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
    ASSERT HIGH(ActorAnimationTable.end - 1) == HIGH(ActorAnimationTable)
    ld      h, HIGH(ActorAnimationTable)
    
    ; Save current bank to restore when finished
    ldh     a, [hCurrentBank]
    push    af
    
    ld      a, [hli]
    ldh     [hCurrentBank], a
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
    call    ActorsSetTiles
    pop     de
    pop     hl
    ; Skip over tile pointer + byte count + next meta-sprite number
    ld      a, l
    add     a, 4
    ld      l, a
    ld      a, h
    ASSERT HIGH(MAX_NUM_ACTORS) == 0
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
ActorsAddSpeedToPos:
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
ActorsUpdateAnimation:
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
    call    ActorsGetAnimationCel
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
    jp      z, ActorsKill
    ASSERT ANIMATION_OVERRIDE_END & ~$80 == 2
    dec     a
    jr      z, .overrideEnd
    ASSERT ANIMATION_SET_TILES & ~$80 == 3
    ASSERT NUM_ANIMATION_SPECIAL_VALUES == 4
    
    ; Stream a set of tiles to VRAM
    call    ActorsSetTiles
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
    
    ; Set cel number
    dec     a   ; Undo inc
    ld      hl, wActorCelTable - MAX_NUM_ACTORS
    add     hl, bc
    ld      [hl], a
    
    ; Copy tiles
    ; WARNING: This will break if the given reset cel does not point to
    ; a set tiles command!
    add     a, a    ; a * 2 (Meta-sprite + Duration)
    inc     a       ; Skip set tiles command byte
    add     a, e
    ld      l, a
    adc     a, d
    sub     a, l
    ld      h, a
    ; Fix actor index
    ASSERT HIGH(MAX_NUM_ACTORS) == 0
    ld      a, c
    sub     a, MAX_NUM_ACTORS
    ld      c, a
    jp      ActorsSetTiles

.goto
    ; Goto: Jump to another position in the animation
    ld      a, [hl] ; a = new cel number
    ld      hl, wActorCelTable
    add     hl, bc
    ld      [hl], a
    
    ; Use this new cel's duration instead
    add     a, a    ; a * 2 (Meta-sprite + Duration)
    add     a, e
    ld      l, a
    adc     a, d
    sub     a, l
    ld      h, a
    jr      .setCountdown

SECTION "Actor Kill", ROM0

; @param    bc  Actor index
ActorsKill::
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
ActorsSetTiles:
    push    bc
    ; Check if the actor index is wrong (for override animations)
    ld      a, c
    cp      a, MAX_NUM_ACTORS
    jr      c, .indexOk
    ; Fix actor index
    ASSERT HIGH(MAX_NUM_ACTORS) == 0
    sub     a, MAX_NUM_ACTORS
    ld      c, a
.indexOk
    ; Get the pointer to the tile data
    ld      a, [hli]
    ld      e, a
    ld      a, [hli]
    ld      d, a
    ASSERT HIGH(MAX_NUM_ACTORS) == 0
    ; Save number of bytes (halved for copy loop unroll)
    ld      b, [hl]
    
    ; Get the pointer to the destination in VRAM
    ASSERT HIGH(MAX_NUM_ACTORS) == 0
    ld      a, c
    swap    a       ; actor num * 16
    ASSERT MAX_NUM_ACTORS & ~$0F == 0
    ; No need to clear low nibble (already 0)
    ld      h, HIGH($8000 >> 3)
    ld      l, a
    ASSERT NUM_ACTOR_RESERVED_TILES == 8
    add     hl, hl  ; actor num * 2
    add     hl, hl  ; actor num * 4
    add     hl, hl  ; actor num * 8
    
    ; Copy the tiles
    ; de = source
    ; hl = destination
    ; b = length / 2
.copyLoop
    ldh     a, [rSTAT]
    and     a, STATF_BUSY
    jr      nz, .copyLoop
    
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
    jr      nz, .copyLoop
    
    pop     bc
    ; Update cel number to skip the command (4 bytes)
    ld      hl, wActorCelTable
    add     hl, bc
    inc     [hl]    ; Command + HIGH(Tile pointer)
    inc     [hl]    ; LOW(Tile pointer) + length
    ret

SECTION "Actor Get Animation Table", ROM0

; Point hl to the current cel in the current actor's animation table
; @param    bc          Actor index
; @param    [hScratch1] Actor type * 3
; @return   hl          Pointer to current animation cel data
; @return   de          Pointer to animation table
ActorsGetAnimationCel:
    ; Find animation table
    ldh     a, [hScratch1]  ; a = actor type * 3
    add     a, LOW(ActorAnimationTable)
    ld      l, a
    ASSERT HIGH(ActorAnimationTable.end - 1) == HIGH(ActorAnimationTable)
    ld      h, HIGH(ActorAnimationTable)
    
    ; Point hl to actor's type's animation table
    ld      a, [hli]
    ldh     [hCurrentBank], a
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
ActorsSetCel::
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
    ASSERT HIGH(ActorAnimationTable.end - 1) == HIGH(ActorAnimationTable)
    ld      h, HIGH(ActorAnimationTable)
    
    ; Point hl to actor's type's animation table
    ld      a, [hli]
    ldh     [hCurrentBank], a
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
    ; Check if tiles need to be copied first
    ld      a, [hli]
    cp      a, ANIMATION_SET_TILES
    jr      nz, .setDuration
    
    ; First copy tiles
    push    hl
    call    ActorsSetTiles
    pop     hl
    ; Skip over tile pointer + byte count + next meta-sprite number
    ld      a, l
    add     a, 4
    ld      l, a
    ld      a, h
    ASSERT HIGH(MAX_NUM_ACTORS) == 0
    adc     a, b    ; b = 0
    ld      h, a
.setDuration
    ; Set animation cel countdown
    ld      a, [hl] ; a = cel duration
    ld      hl, wActorCelCountdownTable
    add     hl, bc
    ld      [hl], a
    
    ; Restore bank
    pop     af
    ldh     [hCurrentBank], a
    ld      [rROMB0], a
    ret

SECTION "Actor Set Animation Override Cel", ROM0

; Set an actor's animation override cel and set the override cel \
; countdown to its starting value
; @param    a           Cel number
; @param    bc          Actor index
; @param    [hScratch1] Actor type * 3
; @return   hl          Pointer to current animation cel data
; @return   de          Pointer to animation table
ActorsSetAnimationOverride::
    ASSERT wActorCelOverrideTable == wActorCelTable + MAX_NUM_ACTORS
    ASSERT wActorCelOverrideCountdownTable == wActorCelCountdownTable + MAX_NUM_ACTORS
    push    bc
    ld      b, a    ; Save cel number
    ASSERT HIGH(MAX_NUM_ACTORS * 2) == HIGH(MAX_NUM_ACTORS)
    ld      a, c
    add     a, MAX_NUM_ACTORS
    ld      c, a
    ld      a, b    ; Restore cel number
    ld      b, 0
    call    ActorsSetCel
    pop     bc
    ret
