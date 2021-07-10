INCLUDE "defines.inc"

SECTION "Actor Type Table", WRAM0

; Type of actor, ACTOR_EMPTY for empty
wActorTypeTable::
    DS MAX_NUM_ACTORS

SECTION "Actor X Position Table", WRAM0

; 8-bit X position, relative to the screen
wActorXPosTable::
    DS MAX_NUM_ACTORS

SECTION "Actor Y Position Table", WRAM0

; 8-bit Y position, relative to the screen
wActorYPosTable::
    DS MAX_NUM_ACTORS

SECTION "Actor Speed Tables", WRAM0

; Q4.4 (reversed) fixed point speeds
; Fractional part added to fractional accumulator, integer part and
; fractional accumulator carry added to position

; Reversed Q4.4 means the fractional part is in the high nibble and the
; integer part is in the low nibble. This means no nibble swapping is
; necessary.

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
    
    ld      bc, 0   ; bc = actor index
.loop
    ld      hl, wActorTypeTable
    add     hl, bc
    ; If actor type is ACTOR_EMPTY, skip this actor
    ld      a, [hli]
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
    ; Update actor's animation cel countdown
    ld      hl, wActorCelCountdownTable
    add     hl, bc
    dec     [hl]
    jr      nz, .noCelUpdate
    
    ; Animation cel countdown reached 0, increment animation cel ID
    ld      hl, wActorCelTable
    add     hl, bc
    inc     [hl]
    
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
    ld      hl, wActorTypeTable
    add     hl, bc
    ld      a, [hl]
    add     a, a    ; a * 2 (Pointer)
    add     a, [hl] ; a * 3 (+Bank)
    add     a, LOW(ActorRoutineTable)
    ld      l, a
    ASSERT HIGH(ActorRoutineTable.end - 1) == HIGH(ActorRoutineTable)
    ld      h, HIGH(ActorRoutineTable)
    
    ld      a, [hli]
    ldh     [hCurrentBank], a
    ld      [rROMB0], a
    ld      a, [hli]
    ld      h, [hl]
    ld      l, a
    rst     JP_HL
    jr      .next

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
    ld      e, a    ; Save speed temporarily in e
    
    ; Get fractional part (in high nibble)
    and     $F0
    ; Add fractional part to fractional accumulator
    ld      hl, wActorXSpeedAccTable
    add     hl, bc
    add     a, [hl]
    ld      [hl], a
    
    ld      a, e    ; Restore speed from e
    rr      e       ; Save carry from fractional part in e
    ; Get integer part (in low nibble)
    and     a, $0F
    ; If the speed is negative, sign extend the integer part
    ; Don't need to do this with the fractional part since it will still
    ; produce a carry at the correct rate
    bit     3, a    ; Sign in bit 3
    jr      z, .positive
    or      a, $F0  ; Sign extend
.positive
    rl      e       ; Restore carry from fractional part
    adc     a, [hl] ; Add integer part + fractional part carry to position
    ld      [hl], a
    
    ret
