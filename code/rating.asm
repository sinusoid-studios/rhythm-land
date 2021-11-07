INCLUDE "constants/hardware.inc"
INCLUDE "constants/other-hardware.inc"
INCLUDE "constants/rating.inc"
INCLUDE "constants/screens.inc"
INCLUDE "constants/transition.inc"
INCLUDE "constants/sfx.inc"
INCLUDE "macros/misc.inc"

SECTION UNION "Game Variables", HRAM

; Temporary storage of the rating type for reference when drawing the
; rating graphic
hRatingType:
    DS 1

; Toggles between 0 and 1 to play the text sound effect for every other
; letter (every letter is too much and sounds like a garbled long tone)
hLetterSFXFlipFlop:
    DS 1

SECTION "Overall Rating Screen Setup", ROM0

ScreenSetupRating::
    ; Reset scroll
    xor     a, a
    ldh     [hSCX], a
    ldh     [hSCY], a
    
    ; Set appropriate LCDC flags
    ld      a, LCDCF_ON | LCDCF_BG8800 | LCDCF_BG9800 | LCDCF_BGON
    ldh     [hLCDC], a
    
    ; Clear the background map
    ld      hl, _SCRN0
    lb      bc, 0, SCRN_Y_B
    call    LCDMemsetMap
    
    ; Set up text engine for rating text
    ld      a, RATING_TEXT_LINE_LENGTH * 8 + 1
    ld      [wTextLineLength], a
    ; Each entry is 1 line
    ld      a, RATING_TEXT_LINE_COUNT
    ld      [wTextNbLines], a
    ld      [wTextRemainingLines], a
    ld      [wNewlinesUntilFull], a
    xor     a, a
    ld      [wTextStackSize], a
    ld      [wTextFlags], a
    ld      a, RATING_TEXT_LETTER_DELAY
    ld      [wTextLetterDelay], a
    ; Set up text tiles
    ld      a, RATING_TEXT_TILES_START
    ld      [wTextCurTile], a
    ld      [wWrapTileID], a
    ld      a, RATING_TEXT_LAST_TILE
    ld      [wLastTextTile], a
    ld      a, HIGH(vRatingTextTiles) & $F0
    ld      [wTextTileBlock], a
    
    ; Reset "flip-flop"
    xor     a, a
    ldh     [hLetterSFXFlipFlop], a
    
    ; Next hit number after the last is the total number of hits in the
    ; current game
    ldh     a, [hNextHitNumber]
    ld      d, a    ; Save for calculating missed hit count
    add     a, a    ; Double total to give weights in 1/2s
    ld      c, a    ; c = denominator
    
    ; Miss: Weight -1
    ld      hl, hHitPerfectCount
    ld      a, [hld]
    ASSERT hHitOKCount == hHitPerfectCount - 1
    add     a, [hl]
    ASSERT hHitBadCount == hHitOKCount - 1
    dec     l
    add     a, [hl]
    ; a = Perfects + OKs + Bads
    cpl
    inc     a
    ; a = -(Perfects + OKs + Bads)
    add     a, d
    ; a = Total - Perfects - OKs - Bads = Misses
    add     a, a    ; Weight 1
    cpl
    inc     a       ; Weight -1
    
    ; OK: Weight 0.5
    ASSERT hHitOKCount == hHitBadCount + 1
    inc     l
    add     a, [hl]
    
    ASSERT hHitPerfectCount == hHitOKCount + 1
    inc     l
    ; Perfect: Weight 1
    add     a, [hl]
    add     a, [hl]
    
    ld      l, LOW(hHitBadCount)
    ld      e, a
    ; Bad: Weight -0.5
    ld      a, [hld]
    cpl
    inc     a
    ld      b, RATING_BAD
    ; If there are 0 Bads, the carry won't be set
    jr      z, .noCarry
    add     a, e    ; Weighted Bads + Total
    ; Check for negative underflow
    jr      nc, .gotRating
    DB      $30     ; jr nc, e8 to consume the next byte
.noCarry
    add     a, e
    ; Score is negative -> go straight to Bad
    rlca    ; Copy bit 7 (sign) to carry
    jr      c, .gotRating
    
    ; Numerator must be less than denominator, but that's fine since
    ; it'll be 100 anyway
    rrca    ; Undo rlca
    cp      a, c
    ld      b, RATING_PERFECT
    jr      nc, .gotRating
    
    ld      b, a
    ; b = numerator, c = denominator
    call    CalcPercentDigit
    ; a = tens digit
    
    ld      b, RATING_BAD
    cp      a, RATING_OK_MIN
    jr      c, .gotRating
    
    ASSERT RATING_OK == RATING_BAD + 1
    inc     b
    cp      a, RATING_GREAT_MIN
    jr      c, .gotRating
    
    ASSERT RATING_GREAT == RATING_OK + 1
    inc     b

; @param    b   Rating type ID
.gotRating
    ; Save rating type ID for drawing the graphic later on
    ld      a, b
    ldh     [hRatingType], a
    
    ; Load appropriate background tiles
    ; Find pointer to tile data
    ; a = rating type
    add     a, a    ; rating type * 2 (Pointer)
    add     a, a    ; rating type * 4 (Length)
    add     a, b    ; rating type * 5 (+Bank)
    add     a, LOW(RatingTilesTable)
    ld      l, a
    ASSERT HIGH(RatingTilesTable.end - 1) == HIGH(RatingTilesTable)
    ld      h, HIGH(RatingTilesTable)
    
    ; Get pointer to tile data
    ld      a, [hli]
    ld      [rROMB0], a
    ld      a, [hli]
    ld      e, a
    ld      a, [hli]
    ld      d, a
    ; Get size of tile data
    ld      a, [hli]
    ld      c, a
    ld      b, [hl]
    ; Copy to VRAM
    ld      hl, $9000
    rst     LCDMemcopy
    
    ; Set up feedback text for this rating
    ; Find current game's part of the rating text table
    ldh     a, [hCurrentScreen]
    ASSERT RATING_TYPE_COUNT == 4
    add     a, a    ; game ID * 2
    add     a, a    ; game ID * 4
    ld      c, a
    add     a, a    ; game ID * RATING_TYPE_COUNT + game ID * 2 (Pointer)
    add     a, c    ; game ID * RATING_TYPE_COUNT + game ID * 3 (+Bank)
    ; Ensure the highest value would fit in a single byte
    ASSERT HIGH((GAME_COUNT - 1) * 12) == 0
    ld      c, a
    
    ; Find pointer to text for this type of rating
    ldh     a, [hRatingType]
    ld      b, a
    add     a, a    ; rating type * 2 (Pointer)
    add     a, b    ; rating type * 3 (+Bank)
    add     a, c    ; c = game offset
    ; Ensure the highest value would fit in a single byte
    ASSERT HIGH(RATING_TYPE_COUNT * 3 + (GAME_COUNT - 1) * 12) == 0
    add     a, LOW(RatingTextTable)
    ld      l, a
    ASSERT HIGH(RatingTextTable.end - 1) == HIGH(RatingTextTable)
    ld      h, HIGH(RatingTextTable)
    
    ; Get pointer to text
    ld      a, [hli]
    ld      b, a    ; b = bank number
    ld      a, [hli]
    ld      h, [hl]
    ld      l, a
    ; hl = pointer to text
    ld      a, TEXT_NEW_STR
    call    PrintVWFText
    ld      hl, vRatingText
    jp      SetPenPosition

SECTION "Overall Rating Screen", ROM0

ScreenRating::
    ; Force the transition to end
    ; Re-disable LYC interrupts
    ld      hl, rIE
    res     IEB_STAT, [hl]
    ; Turn off transition
    ASSERT TRANSITION_STATE_OFF == 0
    xor     a, a
    ldh     [hTransitionState], a
    ; Set palettes
    ld      a, RATING_SCREEN_BGP
    ldh     [hBGP], a
    
.feedbackLoop
    rst     WaitVBlank
    
    ; Play a text sound effect if a letter is about to be drawn this
    ; frame
    ld      a, [wTextNextLetterDelay]
    and     a, a
    jr      nz, .noSFX
    ; A letter is about to be drawn, but only play it for every other
    ; letter
    ldh     a, [hLetterSFXFlipFlop]
    xor     a, 0 ^ 1    ; Toggle between 0 and 1
    ldh     [hLetterSFXFlipFlop], a
    jr      z, .noSFX
    ; Every other letter, play the text sound effect
    ld      b, SFX_TEXT
    call    SFX_Play
.noSFX
    ; Update feedback text
    call    PrintVWFChar
    call    DrawVWFChars
    
    ; Calling SoundSystem_Process directly instead of SoundUpdate
    ; because this is in ROM0 and there is no sync data to be looking
    ; for
    call    SoundSystem_Process
    
    ; Text engine sets the high byte of the source pointer to $FF when
    ; the end command (terminator) is reached
    ld      a, [wTextSrcPtr + 1]
    inc     a   ; ($FF + 1) & $FF == 0
    jr      nz, .feedbackLoop

    ; Text is finished -> delay a bit before drawing the rating graphic
    ld      a, RATING_GRAPHIC_DELAY
    ldh     [hScratch1], a
.delayLoop
    rst     WaitVBlank
    call    SoundSystem_Process
    ldh     a, [hScratch1]
    dec     a
    ldh     [hScratch1], a
    jr      nz, .delayLoop
    
    ; Draw the rating graphic
    ; Load appropriate background map
    ; Find pointer to map data
    ldh     a, [hRatingType]
    ld      b, a
    add     a, a    ; rating type * 2 (Pointer)
    add     a, b    ; rating type * 3 (+Bank)
    add     a, LOW(RatingMapTable)
    ld      l, a
    ASSERT HIGH(RatingMapTable.end - 1) == HIGH(RatingMapTable)
    ld      h, HIGH(RatingMapTable)
    
    ; Get pointer to map data
    ld      a, [hli]
    ld      [rROMB0], a
    ld      a, [hli]
    ld      e, a
    ld      d, [hl]
    ; Copy to VRAM
    ld      hl, vRatingGraphic
    ld      c, RATING_GRAPHIC_HEIGHT
    call    LCDMemcopyMap
    
    ; Start the rating theme
    ; Get pointer to music data for this rating type
    ldh     a, [hRatingType]
    add     a, a    ; rating type * 2 (Inst pointer)
    ld      b, a
    add     a, a    ; rating type * 4 (Music pointer)
    add     a, b    ; rating type * 6 (Inst bank + Music bank)
    add     a, LOW(RatingThemeTable)
    ld      l, a
    ASSERT HIGH(RatingThemeTable.end - 1) == HIGH(RatingThemeTable)
    ld      h, HIGH(RatingThemeTable)
    ; Prepare Insts
    ld      a, [hli]
    ld      c, a    ; c = bank number
    ld      a, [hli]
    ld      e, a
    ; Don't use `ld d, [hl]` because the auto-increment is needed for
    ; getting the Music pointer
    ld      a, [hli]
    ld      d, a
    ; de = Inst pointer
    push    hl  ; Save to get the Music pointer
    call    Music_PrepareInst
    
    ; Play Music
    pop     hl
    ld      a, [hli]
    ld      c, a    ; c = bank number
    ld      a, [hli]
    ld      d, [hl]
    ld      e, a
    ; de = Music pointer
    call    Music_Play
    
    ; Wait for player input
.wait
    rst     WaitVBlank
    
    ldh     a, [hTransitionState]
    ASSERT TRANSITION_STATE_OFF == 0
    and     a, a
    jr      z, .noTransition
    
    call    TransitionUpdate
    call    SoundSystem_Process
    ; Transitioning -> don't take player input
    jr      .wait
    
.noTransition
    call    SoundSystem_Process
    ldh     a, [hNewKeys]
    and     a, PADF_A | PADF_START
    jr      z, .wait
    
    ld      a, SCREEN_GAME_SELECT
    call    TransitionStart
    jr      .wait

SECTION "Percentage Calculation", ROM0

; Original code copyright (c) 2018 Damian Yerrick (PinoBatch)
; Taken from Libbet and the Magic Floor: <https://github.com/pinobatch/libbet>
; Formatting modified in this file.
; See ATTRIBUTION.md for more information.

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
