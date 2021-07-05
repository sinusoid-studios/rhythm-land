SECTION "Test Game", ROMX

xGameTest::
    ; Start music
    ld      bc, BANK(Inst_FileSelect)
    ld      de, Inst_FileSelect
    call    Music_PrepareInst
    ld      bc, BANK(Music_FileSelect)
    ld      de, Music_FileSelect
    call    Music_Play

.loop
    halt
    jr      .loop
