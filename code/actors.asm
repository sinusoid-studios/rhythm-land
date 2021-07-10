INCLUDE "defines.inc"

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

; Q4.4 fixed point speeds
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

SECTION "Actor Animation Cel Table", WRAM0

; Index of the current animation cel, used to find meta-sprite data in
; the actor's type's animation table
wActorCelTable::
    DS MAX_NUM_ACTORS

SECTION "Actor Animation Cel Countdown Table", WRAM0

; Number of frames left until the next animation cel
wActorCelCountdownTable::
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
    ASSERT MAX_NUM_ACTORS < 256
    inc     c
    ld      a, c
    cp      a, MAX_NUM_ACTORS
    jr      c, .loop
    
    ; Restore bank
    pop     af
    ldh     [hCurrentBank], a
    ld      [rROMB0], a
    
    ret

.update
    ; Save this actor's type * 3 for quick access
    dec     a       ; Undo inc
    add     a, a    ; a * 2 (Pointer)
    add     a, [hl] ; a * 3 (+Bank)
    ldh     [hScratch], a
    
    ; Update actor's animation cel countdown
    ld      hl, wActorCelCountdownTable
    add     hl, bc
    dec     [hl]
    jr      nz, .noCelUpdate
    
    ; Animation cel countdown reached 0, increment animation cel ID
    ld      hl, wActorCelTable
    add     hl, bc
    inc     [hl]
    
    call    ActorsGetAnimationCel
    ; Check if this is the goto special value
    ld      a, [hli]
    ASSERT ANIMATION_GOTO == -1
    inc     a
    jr      nz, .noGoto
    
    ld      a, [hl] ; a = new cel number
    ld      hl, wActorCelTable
    add     hl, bc
    ld      [hl], a
    
    ; Use this new cel's duration
    add     a, a    ; a * 2 (Meta-sprite + Duration)
    add     a, e
    ld      l, a
    adc     a, d
    sub     a, l
    ld      h, a
    inc     hl      ; Get duration
.noGoto
    ld      a, [hl]
    ld      hl, wActorCelCountdownTable
    add     hl, bc
    ld      [hl], a
    
.noCelUpdate
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
    ASSERT MAX_NUM_ACTORS * 2 < 256
    ld      a, c
    add     a, MAX_NUM_ACTORS
    ld      c, a
    call    ActorsAddSpeedToPos
    pop     bc
    
    ; Call the actor's update routine
    ldh     a, [hScratch]   ; a = actor type
    add     a, LOW(ActorRoutineTable)
    ld      l, a
    adc     a, HIGH(ActorRoutineTable)
    sub     a, l
    ld      h, a
    
    ld      a, [hli]
    ldh     [hCurrentBank], a
    ld      [rROMB0], a
    ld      a, [hli]
    ld      h, [hl]
    ld      l, a
    rst     JP_HL
    
    ; Render this actor
    
    ; Save actor's Y position for use in meta-sprites
    ld      hl, wActorYPosTable
    add     hl, bc
    ld      a, [hl]
    ldh     [hActorYPos], a
    
    ; Save actor's X position for use in meta-sprites
    ld      hl, wActorXPosTable
    add     hl, bc
    ld      a, [hl]
    ldh     [hActorXPos], a
    
    call    ActorsGetAnimationCel
    
    ld      a, [hl]     ; a = meta-sprite number
    add     a, a        ; a * 2 (Pointer)
    ld      e, a        ; Save in e
    
    ; Find meta-sprite table
    ldh     a, [hScratch]   ; a = actor type
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
    ASSERT MAX_NUM_ACTORS < 256
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
    ; Use first animation cel's duration
    inc     l       ; Meta-sprite, Duration (Move to duration)
    ld      a, [hl]
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
    
    xor     a, a
    
    ; Reset actor speed
    ld      hl, wActorXSpeedTable
    add     hl, bc
    ld      [hl], a
    ld      hl, wActorYSpeedTable
    add     hl, bc
    ld      [hl], a
    ld      hl, wActorXSpeedAccTable
    add     hl, bc
    ld      [hl], a
    ld      hl, wActorYSpeedAccTable
    add     hl, bc
    ld      [hl], a
    
    ; Reset actor animation cel
    ld      hl, wActorCelTable
    add     hl, bc
    ld      [hl], a
    
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
    
    ; Get fractional part in high nibble
    and     $F0
    ; Add fractional part to fractional accumulator
    ld      hl, wActorXSpeedAccTable
    add     hl, bc
    add     a, [hl]
    ld      [hl], a
    
    ld      a, e    ; Restore speed from e
    rr      e       ; Save carry from fractional part in e
    ; Get integer part in low nibble
    and     a, $0F
    ; If the speed is negative, sign extend the integer part
    ; Don't need to do this with the fractional part since it will still
    ; produce a carry at the correct rate
    bit     3, a    ; Sign in bit 3
    jr      z, .positive
    or      a, $F0  ; Sign extend
.positive
    ld      hl, wActorXPosTable
    add     hl, bc
    rl      e       ; Restore carry from fractional part
    adc     a, [hl] ; Add integer part + fractional part carry to position
    ld      [hl], a
    
    ret

SECTION "Actor Get Animation Table", ROM0

; Point hl to the current cel in the current actor's animation table
; @param    bc          Actor index
; @param    [hScratch]  Actor type * 3
; @return   hl          Pointer to current animation cel data
ActorsGetAnimationCel:
    ; Find animation table
    ldh     a, [hScratch]   ; a = actor type * 3
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
    ; Get current cel's duration
    add     a, a    ; a * 2 (Meta-sprite + Duration)
    add     a, e
    ld      l, a
    adc     a, d
    sub     a, l
    ld      h, a
    
    ret
