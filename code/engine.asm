INCLUDE "defines.inc"

SECTION "Engine Variables", HRAM

; Bank number of current game's hit table
; Also used for telling whether or not there are any more hits left in
; the game. No more hits = 0
hHitTableBank::
    DS 1
; Pointer to current position in current game's hit table
hHitTablePointer:
.low
    DS 1
.high
    DS 1
; Keys that are used as hit keys in the current game
hGameHitKeys::
    DS 1
; Keys that the player must press for the next hit
hNextHitKeys::
    DS 1
; Keys that the player must press for the last hit
hLastHitKeys::
    DS 1
; Number of frames until the next hit
hNextHit::
.low::
    DS 1
.high::
    DS 1
; Number of frames since the last hit
hLastHit::
.low::
    DS 1
.high::
    DS 1

; Number of Bad hits the player made (not on-time)
hHitBadCount::
    DS 1
; Number of OK hits the player made (somewhat on-time)
hHitOkCount::
    DS 1
; Number of Perfect hits the player made (right on time)
hHitPerfectCount::
    DS 1

; Index of the next hit, used for disallowing making a hit multiple
; times
hNextHitNumber::
    DS 1
; Index of the last hit the player made that wasn't missed, used for
; disallowing making a hit multiple times
hLastRatedHitNumber:
    DS 1

SECTION "Engine Initialization", ROM0

; Prepare the engine for a game
; @param    c   Bank number of hit table
; @param    hl  Pointer to hit table
EngineInit::
    ; Save current bank to restore when finished
    ldh     a, [hCurrentBank]
    push    af
    
    ; Set hit table bank
    ld      a, c
    ldh     [hHitTableBank], a
    ldh     [hCurrentBank], a
    ld      [rROMB0], a
    ; Save this game's hit keys
    ld      a, [hli]
    ldh     [hGameHitKeys], a
    ; Save hit table pointer
    ld      a, l
    ldh     [hHitTablePointer.low], a
    ld      a, h
    ldh     [hHitTablePointer.high], a
    call    SetNextHit.skip
    
    ; Reset hit rating counts
    ld      hl, hHitBadCount
    xor     a, a
    ld      [hli], a
    ASSERT hHitOkCount == hHitBadCount + 1
    ld      [hli], a
    ASSERT hHitPerfectCount == hHitOkCount + 1
    ld      [hli], a
    ; Reset hit numbers
    ASSERT hNextHitNumber == hHitPerfectCount + 1
    ld      [hli], a
    ASSERT hLastRatedHitNumber == hNextHitNumber + 1
    dec     a       ; Haven't rated any hits
    ld      [hli], a
    
    jp      BankedReturn

SECTION "Engine Update", ROM0

; Advance a frame in the cue table
EngineUpdate::
    ldh     a, [hNewKeys]
    and     a, a
    jr      nz, .hit
    
    ; Check if this game uses release hits
    ldh     a, [hGameHitKeys]
    bit     HITB_RELEASE, a
    jr      z, .noHit
    
    ldh     a, [hReleasedKeys]
    and     a, a
    jr      z, .noHit
.hit
    ; Check if these keys are hit keys in this game
    ld      b, a
    ldh     a, [hGameHitKeys]
    and     a, b
    ; These keys do nothing in this game; ignore
    jr      z, .noHit
    
    ; Player pressed keys: Give rating based on how on-time it was
    ld      hl, hLastHit.high
    ld      e, LOW(hLastHitKeys)
    ld      d, h
    
    ; If the high byte of counter is non-zero, just count it as 2 Bads
    ld      b, %11  ; 2 bits set -> increment by 2
    ld      a, [hli]
    and     a, a
    ASSERT hHitBadCount == hLastHit.high + 1
    jr      z, .notReallyBad
    ld      l, LOW(hNextHit.high)
    ld      a, [hl]
    ld      l, LOW(hHitBadCount)
    ; High byte is always 1 higher than it really is (for using Z with `dec`)
    dec     a
    jr      nz, .countLoop
    
.notReallyBad
    ; The player is actually competent -> check how much so
    ld      l, LOW(hLastHit.low)
    ld      a, [hl]
    ; Check if the next hit is closer (player is early)
    ld      l, LOW(hNextHit.low)
    cp      a, [hl]
    ld      c, a    ; Save on-timeness
    ldh     a, [hNextHitNumber]
    dec     a       ; This hit is the previous hit (doesn't affect carry)
    jr      c, .notEarly
    
    ld      c, [hl] ; Get on-timeness of next hit
    ASSERT hNextHitKeys == hLastHitKeys - 1
    dec     e       ; Use next hit keys instead of last hit keys
    inc     a       ; This hit is the next hit
    
.notEarly
    ; Save hit number
    ld      l, a
    ldh     [hScratch1], a
    
    ; Check if the player pressed the hit keys
    ld      a, [de]
    bit     HITB_RELEASE, a
    jr      nz, .release
    ldh     a, [hNewKeys]
    DB      $C2     ; jp nz, a16 to consume the next 2 bytes
.release
    ldh     a, [hReleasedKeys]
    
    ld      b, a
    ld      a, [de]
    res     HITB_RELEASE, a
    and     a, b
    ; The player hit the wrong keys
    jr      z, .wrong
    
    ld      b, a    ; Save pressed hit keys for rating count
    
    ; Check if this hit was already rated (disallow making it again)
    ldh     a, [hLastRatedHitNumber]
    cp      a, l    ; l = this hit's number
    ; Hit was made again, count it as Bad (negatively affect overall
    ; rating)
    ld      l, LOW(hHitBadCount)
    jr      z, .countLoop
    
    ld      a, c    ; Restore on-timeness
    ; Bad
    cp      a, HIT_OK_WINDOW / 2
    jr      nc, .countLoop
    
    ; OK
    cp      a, HIT_PERFECT_WINDOW / 2
    ldh     a, [hScratch1]  ; Restore hit number
    ASSERT hHitOkCount == hHitBadCount + 1
    inc     l       ; Doesn't affect carry
    jr      nc, .gotRating
    
    ; Perfect
    ASSERT hHitPerfectCount == hHitOkCount + 1
    inc     l

.gotRating
    ; Bad hits don't go here; give the player a chance to do better
    ldh     [hLastRatedHitNumber], a
.countLoop
    ; Increment number of this rating of hit for each pressed hit key
    inc     [hl]
.next
    srl     b       ; b = pressed hit keys
    jr      z, .noHit
    jr      nc, .next
    jr      .countLoop

.wrong
    ; The player hit the wrong keys -> give them a Bad for every wrong
    ; key
    ldh     a, [hGameHitKeys]
    and     a, b    ; b = [hNewKeys]
    ld      l, LOW(hHitBadCount)
    jr      .countLoop

.noHit
    ; Update hit timing
    
    ; Save current bank to restore when finished
    ldh     a, [hCurrentBank]
    push    af
    
    ; Last hit moves farther away
    ld      hl, hLastHit
    inc     [hl]
    jr      nz, :+
    inc     l
    inc     [hl]
:
    
    ldh     a, [hHitTableBank]
    and     a, a    ; Bank number 0 = no more hits (finished)
    jr      z, .updateCues
    
    ; Next hit comes closer
    ld      l, LOW(hNextHit)
    dec     [hl]
    jr      nz, .updateCues
    inc     l
    dec     [hl]
    call    z, SetNextHit

.updateCues
    ; Check for any cues
    ld      a, [wMusicSyncData]
    ld      b, a    ; Save for multiplying by 3
    add     a, a    ; Bit 7 set = cue
    jr      nc, BankedReturn
    
    ; Get a pointer to the cue's subroutine
    ; a = cue ID * 2
    res     7, b
    add     a, b    ; a * 3 (+Bank)
    add     a, LOW(CueRoutineTable)
    ld      l, a
    ASSERT HIGH(CueRoutineTable.end - 1) == HIGH(CueRoutineTable)
    ld      h, HIGH(CueRoutineTable)
    
    ; Call the subroutine
    ld      a, [hli]
    ldh     [hCurrentBank], a
    ld      [rROMB0], a
    ld      a, [hli]
    ld      h, [hl]
    ld      l, a
    rst     JP_HL
    
    ; Fall-through

BankedReturn:
    ; Restore caller's bank
    pop     af
    ldh     [hCurrentBank], a
    ld      [rROMB0], a
    ret

SECTION "Engine Next Hit Preparation", ROM0

SetNextHit:
    ; Move to next hit
    ld      hl, hNextHitNumber
    inc     [hl]
    
    ; Get the current position in the hit table
    ldh     a, [hHitTableBank]
    ldh     [hCurrentBank], a
    ld      [rROMB0], a
    ld      hl, hHitTablePointer
    ld      a, [hli]
    ld      h, [hl]
    ld      l, a
.skip
    ; Get next hit delay
    ld      a, [hli]
    ASSERT HITS_END == -1
    inc     a       ; a = -1
    jr      z, .hitsEnd
    
    dec     a       ; Undo inc
    ; Set hit timing
    ldh     [hNextHit.low], a
    ld      a, [hli]
    ldh     [hNextHit.high], a
    ; Set hit keys
    ldh     a, [hNextHitKeys]
    ldh     [hLastHitKeys], a
    ld      a, [hli]
    ldh     [hNextHitKeys], a
    
    ; Save new pointer
    ld      a, l
    ldh     [hHitTablePointer.low], a
    ld      a, h
    ldh     [hHitTablePointer.high], a
.finished
    xor     a, a
    ldh     [hLastHit.low], a
    ldh     [hLastHit.high], a
    ret

.hitsEnd
    ; No more hits
    ; Set hit table bank to 0 to signal no hit updates
    ; a = 0
    ldh     [hHitTableBank], a
    jr      .finished
