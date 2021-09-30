INCLUDE "constants/hardware.inc"
INCLUDE "constants/hits.inc"
INCLUDE "constants/engine.inc"

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

; The type of rating the last hit the player made got
; See constants/engine.inc for possible values
hLastHitRating::
    DS 1

hHitRatingCounts:
; Number of Bad hits the player made (not on-time)
hHitBadCount::
    DS 1
; Number of OK hits the player made (somewhat on-time)
hHitOKCount::
    DS 1
; Number of Perfect hits the player made (right on time)
hHitPerfectCount::
    DS 1

; Index of the next hit, used for disallowing making a hit multiple
; times
hNextHitNumber::
    DS 1
; Index of the last hit the player made, used for determining what to do
; in games where not all of the same type of hit do the same thing
hLastPlayerHitNumber::
    DS 1
; Index of the last hit the player made that wasn't a Miss or Bad, used
; for disallowing making a hit multiple times
hLastRatedHitNumber::
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
    ld      hl, hLastHitRating
    ASSERT HIT_BAD == 0
    xor     a, a
    ld      [hli], a
    ASSERT hHitBadCount == hLastHitRating + 1
    ld      [hli], a
    ASSERT hHitOKCount == hHitBadCount + 1
    ld      [hli], a
    ASSERT hHitPerfectCount == hHitOKCount + 1
    ld      [hli], a
    ; Reset hit numbers
    ASSERT hNextHitNumber == hHitPerfectCount + 1
    ld      [hli], a
    dec     a       ; Player hasn't made any hits yet
    ASSERT hLastPlayerHitNumber == hNextHitNumber + 1
    ld      [hli], a
    ASSERT hLastRatedHitNumber == hLastPlayerHitNumber + 1
    ld      [hli], a
    
    jp      BankedReturn

SECTION "Engine Update", ROM0

; Update music and SFX, advance a frame in the hit table, rate any hits
; the player makes, and call cue handlers
EngineUpdate::
    ; Check for game pause
    ldh     a, [hNewKeys]
    bit     PADB_START, a
    call    nz, Pause
    
    call    SoundUpdate
    
    ldh     a, [hNewKeys]
    and     a, a
    jr      nz, .hit
    
    ; Check if this game uses release hits
    ldh     a, [hGameHitKeys]
    bit     HITB_RELEASE, a
    jp      z, .noHit
    
    ldh     a, [hReleasedKeys]
    and     a, a
    jp      z, .noHit
.hit
    ; Check if these keys are hit keys in this game
    ld      b, a
    ldh     a, [hGameHitKeys]
    and     a, b
    ; These keys do nothing in this game; ignore
    jp      z, .noHit
    
    ; Player pressed keys: Give rating based on how on-time it was
    ld      hl, hLastHit.high
    ld      e, LOW(hLastHitKeys)
    ld      d, h
    
    ; If the high byte of counter is non-zero, just count it as 2 Bads
    ld      b, %11  ; 2 bits set -> increment by 2
    
    ld      a, [hld]
    and     a, a
    ldh     a, [hNextHit.high]
    jr      z, .lastNotReallyBad
    ; Really far from the last hit, how's the next hit?
    and     a, a
    ld      l, LOW(hHitBadCount)
    jr      nz, .countLoop
    
    ; Next hit is closer than the last (player is early)
    ASSERT hNextHitKeys == hLastHitKeys - 1
    dec     e
    ; de = hNextHitKeys
    ldh     a, [hNextHit.low]
    ld      c, a
    ; c = on-timeness
    ldh     a, [hNextHitNumber]
    ; a = hit number
    jr      .gotCloserHit

.useLast
    ; de = hLastHitKeys
    ldh     a, [hLastHit.low]
    ld      c, a
    ; c = on-timeness
    ldh     a, [hNextHitNumber]
    dec     a
    ; a = hit number
    jr      .gotCloserHit

.lastNotReallyBad
    ; The last hit is not really far, how's the next hit?
    ; a = [hNextHit.high]
    and     a, a
    jr      nz, .useLast
    
    ; Both hits are not really far -> compare low bytes
    ld      a, [hl] ; hl = hLastHit.low
    ; Check which hit (next or last) is closer
    ld      l, LOW(hNextHit.low)
    cp      a, [hl]
    ld      c, a    ; Save on-timeness
    ldh     a, [hNextHitNumber]
    dec     a       ; This hit is the previous hit (doesn't affect carry)
    ; The last hit is closer (player is late)
    jr      c, .gotCloserHit
    
    ; The next hit is closer (player is early)
    ld      c, [hl] ; Get on-timeness of next hit
    ASSERT hNextHitKeys == hLastHitKeys - 1
    dec     e       ; Use next hit keys instead of last hit keys
    inc     a       ; This hit is the next hit
    
.gotCloserHit
    ; Save hit number
    ld      l, a
    ldh     [hScratch1], a
    
    ; Check if the player pressed the hit keys
    ld      a, [de] ; de = hLastHitKeys or hNextHitKeys
    bit     HITB_RELEASE, a
    res     HITB_RELEASE, a
    ld      d, a    ; Save hit keys
    ; Release hit bit was set -> use hReleasedKeys
    jr      nz, .release
    ; Release hit bit not set -> use hNewKeys
    ldh     a, [hNewKeys]
    DB      $C2     ; jp nz, a16 to consume the next 2 bytes
.release
    ldh     a, [hReleasedKeys]
    ld      e, a    ; Save pressed keys
    ; Get pressed hit keys
    and     a, d    ; d = hit keys
    ; a = pressed hit keys
    ; If there are no pressed hit keys, all the keys the player pressed
    ; were wrong -> skip normal rating stuff
    jr      z, .wrong
    
    ld      b, a    ; Save pressed hit keys for rating count
    
    ; Check if this hit was already rated (disallow making it again)
    ; This comes after the block above so the values in D and E are
    ; correct for the block at .wrong
    ldh     a, [hLastRatedHitNumber]
    cp      a, l    ; l = hit number
    ; Hit was made again, count it as Bad (negatively affect overall
    ; rating)
    ld      l, LOW(hHitBadCount)
    jr      z, .gotRatingBad
    
    ; The player has done everything right... but were they on-time?
    ld      a, c    ; Restore on-timeness
    
    ; Check for Bad
    cp      a, HIT_OK_WINDOW / 2
    ; If on-timeness is outside the OK window, give Bad
    ; hl = hHitBadCount
    ldh     a, [hScratch1]  ; Restore hit number
    jr      nc, .gotRatingBad
    
    ; Check for OK
    ld      a, c    ; Restore on-timeness
    cp      a, HIT_PERFECT_WINDOW / 2
    ; If on-timeness is outside the Perfect window but inside the OK
    ; window, give OK
    ldh     a, [hScratch1]  ; Restore hit number
    ASSERT hHitOKCount == hHitBadCount + 1
    inc     l       ; Doesn't affect carry
    jr      nc, .gotRating
    
    ; On-timeness is inside the Perfect window -> give Perfect
    ASSERT hHitPerfectCount == hHitOKCount + 1
    inc     l

.gotRating
    ; Bad hits don't go here; give the player a chance to do better
    ldh     [hLastRatedHitNumber], a
.gotRatingBad
    ldh     [hLastPlayerHitNumber], a
.countLoop
    ; Increment count of this rating of hit for each pressed hit key
    ld      a, [hl]
    inc     a
    ; Clamp the counter to max value (2^8-1) to prevent overflow
    jr      z, .next
    ld      [hl], a
.next
    srl     b       ; b = pressed hit keys
    jr      z, .rated
    jr      nc, .next
    jr      .countLoop

.rated
    ; Set the type of rating this hit got
    ASSERT LOW(hHitBadCount) - LOW(hHitRatingCounts) == HIT_BAD
    ASSERT LOW(hHitOKCount) - LOW(hHitRatingCounts) == HIT_OK
    ASSERT LOW(hHitPerfectCount) - LOW(hHitRatingCounts) == HIT_PERFECT
    ld      a, l
    sub     a, LOW(hHitRatingCounts)
    ldh     [hLastHitRating], a
.wrong
    ; Give the player a Bad for every wrong key they pressed
    ld      a, d    ; d = hit keys
    cpl
    ld      b, a
    ; b = non-hit keys
    ldh     a, [hGameHitKeys]
    and     a, b    ; b = non-hit keys
    ; a = non-game hit keys
    and     a, e    ; e = pressed keys
    ; a = pressed non-game hit keys
    
    and     a, ~HITF_RELEASE    ; Can't use `res` because it doesn't change Z
    ; No wrong keys
    jr      z, .noHit
    
    ld      b, a    ; b = wrong keys
    ; Set last player hit number
    ldh     a, [hScratch1]  ; This hit's number
    ldh     [hLastPlayerHitNumber], a
    
    ld      l, LOW(hHitBadCount)
.wrongCountLoop
    inc     [hl]
.wrongNext
    srl     b   ; b = wrong keys
    jr      z, .noHit
    jr      nc, .wrongNext
    jr      .wrongCountLoop
.noHit
    ; Update hit timing
    
    ; Save current bank to restore when finished
    ldh     a, [hCurrentBank]
    push    af
    
    ; Last hit moves farther away
    ld      hl, hLastHit
    inc     [hl]
    jr      nz, .noCarry
    inc     l
    inc     [hl]
.noCarry
    
    ldh     a, [hHitTableBank]
    and     a, a    ; Bank number 0 = no more hits (finished)
    jr      z, .updateCues
    
    ; Next hit comes closer
    ld      l, LOW(hNextHit)
    ld      a, [hl] ; Save current value of low byte
    dec     [hl]
    and     a, a    ; If previous value was 0, there is a borrow
    ; Not zero, no borrow
    jr      nz, .updateCues
    
    ; Borrow from low byte
    inc     l
    ld      a, [hl] ; Save current value of high byte
    dec     [hl]
    and     a, a    ; Both bytes were 0 -> time to move on to the next hit
    call    z, SetNextHit

.updateCues
    ; Check for any cues
    ld      a, [wMusicSyncData]
    ASSERT SYNC_NONE == -1
    inc     a
    jr      z, BankedReturn
    dec     a       ; Undo inc
    ld      b, a    ; Save for multiplying by 3
    add     a, a    ; Bit 7 set = cue
    jr      nc, BankedReturn
    
    ; Get a pointer to the cue's subroutine
    ; a = cue ID * 2
    res     7, b
    add     a, b    ; a * 3 (+Bank)
    add     a, LOW(CueRoutineTable)
    ld      l, a
    ASSERT WARN, HIGH(CueRoutineTable.end - 1) != HIGH(CueRoutineTable)
    adc     a, HIGH(CueRoutineTable)
    sub     a, l
    ld      h, a
    
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
    ld      [rROMB0], a
    ld      hl, hHitTablePointer
    ld      a, [hli]
    ld      h, [hl]
    ld      l, a
.skip
    ; Get next hit delay
    ld      a, [hli]
    ASSERT HITS_END == 0
    and     a, a
    jr      z, .hitsEnd
    
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
    xor     a, a
.finished
    ldh     [hLastHit.high], a
    inc     a
    ldh     [hLastHit.low], a
    ; frames since last hit = 1
    ret

.hitsEnd
    ; No more hits
    ; Set hit table bank to 0 to signal no hit updates
    ; a = 0
    ldh     [hHitTableBank], a
    jr      .finished
