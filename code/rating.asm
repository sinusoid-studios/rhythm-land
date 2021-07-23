INCLUDE "constants/hardware.inc"
INCLUDE "constants/engine.inc"
INCLUDE "constants/games.inc"
INCLUDE "constants/game-select.inc"
INCLUDE "constants/transition.inc"

SECTION "Overall Rating Screen", ROM0

RatingScreen::
    ; Next hit number after the last is the total number of hits in the
    ; current game
    ldh     a, [hNextHitNumber]
    ld      d, a
    add     a, a    ; Double total to give weights in 1/2s
    ld      c, a    ; c = denominator
    
    ; Miss: Weight -0.5
    ld      hl, hHitPerfectCount
    ld      a, [hld]
    ASSERT hHitOkCount == hHitPerfectCount - 1
    add     a, [hl]
    ; a = Perfects + OKs
    cpl
    inc     a
    ; a = -(Perfects + OKs)
    add     a, d
    ; a = Total - Perfects - OKs = Misses
    cpl
    inc     a       ; Weight -0.5
    
    ; OK: Weight 0.5
    add     a, [hl]
    
    ASSERT hHitPerfectCount == hHitOkCount + 1
    inc     l
    ; Perfect: Weight 1
    add     a, [hl]
    add     a, [hl]
    
    ld      l, LOW(hHitBadCount)
    ld      b, a
    ; Bad: Weight -0.5
    ld      a, [hld]
    cpl
    inc     a
    add     a, b
    
    ld      hl, vGameID + (3 * SCRN_VX_B)
    
    ; Score is negative -> go straight to Bad
    bit     7, a
    jr      nz, .bad
    
    ; Numerator must be less than denominator, but that's fine since
    ; it'll be 100 anyway
    cp      a, c
    jr      nc, .perfect
    
    ld      b, a
    ; b = numerator, c = denominator
    call    CalcPercentDigit
    ; a = tens digit
    
    cp      a, RATING_OK_MIN
    jr      c, .bad
    cp      a, RATING_EXCELLENT_MIN
    jr      c, .ok
    
    ; Excellent
    ld      a, $E
    jr      .draw

.ok
    ld      a, $0
    jr      .draw

.bad
    ld      a, $B
    jr      .draw

.perfect
    ld      a, $FF
    ; Fall-through

.draw
    call    LCDDrawHex
.wait
    rst     WaitVBlank
    
    ldh     a, [hTransitionState]
    ASSERT TRANSITION_STATE_OFF == 0
    and     a, a
    jr      z, .noTransition
    
    call    TransitionUpdate
    ; Transitioning -> don't take player input
    jr      .wait
    
.noTransition
    ldh     a, [hNewKeys]
    and     a, PADF_A | PADF_START
    jr      z, .wait
    
    ld      a, ID_GAME_SELECT
    call    TransitionStart
    jr      .wait

SECTION "Percentage Calculation", ROM0

; Original code copyright 2018 Damian Yerrick
; Taken from Libbet and the Magic Floor
; <https://github.com/pinobatch/libbet>
; Modified slightly in this file

; Calculates one digit of converting a fraction to a percentage
; @param    b   Numerator, less than c
; @param    c   Denominator, greater than 0
; @return   a   floor(10 * b / c)
; @return   b   10 * b % c
CalcPercentDigit::
    ld      de, $1000
    
    ; Bit 3: A.E = B * 1.25
    ld      a, b
    srl     a
    rr      e
    srl     a
    rr      e
    add     a, b
    jr      .firstCarry
    
    ; Bits 2-0: mul A.E by 2
.bitLoop
    rl      e
    adc     a
.firstCarry
    jr      c, .sub
    cp      a, c
    jr      c, .noSub
.sub
    ; Usually A >= C so subtracting C won't borrow. But if we arrived
    ; via .sub, A > 256 so even though 256 + A >= C, A < C.
    sub     a, c
    and     a, a
.noSub
    rl      d
    jr      nc, .bitLoop
    
    ld      b, a
    ; Binary to decimal subtracts if trial subtraction has no borrow.
    ; 6502/ARM carry: 0: borrow; 1: no borrow
    ; 8080 carry: 1: borrow; 0: no borrow
    ; The 6502 interpretation is more convenient for binary to decimal
    ; conversion, so convert to 6502 discipline
    ld      a, $0F
    xor     a, d
    ret
