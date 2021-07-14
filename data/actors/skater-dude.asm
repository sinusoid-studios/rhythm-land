INCLUDE "defines.inc"

SECTION "Skater Dude Actor Animation Data", ROMX

xActorSkaterDudeAnimation::
    ; Skating
    DB 0, MUSIC_SKATER_DUDE_SPEED
    DB 1, MUSIC_SKATER_DUDE_SPEED
    DB 2, MUSIC_SKATER_DUDE_SPEED
    DB 3, MUSIC_SKATER_DUDE_SPEED
    DB ANIMATION_GOTO, 0
    
    ; Jumping
    DB 4, 2
    DB 5, 2
    DB 6, 2
    DB 7, (MUSIC_SKATER_DUDE_SPEED * 4) - (2 * 3) - (5 * 3)
    DB 8, 5
    DB 9, 5
    DB 10, 5
    DB ANIMATION_GOTO, 1
    
    ; Falling
    DB 11, 4
    DB 12, 4
    DB 13, 4
    DB 14, 4
    DB 15, 4
    DB 16, 4
    DB 17, 4
    DB 18, (MUSIC_SKATER_DUDE_SPEED * 4) - (4 * 7)
    DB 19, MUSIC_SKATER_DUDE_SPEED * 1
    DB 18, MUSIC_SKATER_DUDE_SPEED * 1
    DB 19, MUSIC_SKATER_DUDE_SPEED * 1
    DB 18, MUSIC_SKATER_DUDE_SPEED * 1
    DB ANIMATION_GOTO, 0

SECTION "Skater Dude Actor Meta-Sprite Data", ROMX

xActorSkaterDudeMetasprites::
    ; Skating
    DW .skating1
    DW .skating2
    DW .skating3
    DW .skating4
    
    ; Jumping
    DW .jumping1
    DW .jumping2
    DW .jumping3
    DW .jumping4
    DW .jumping5
    DW .jumping6
    DW .jumping7
    
    ; Falling
    DW .falling1
    DW .falling2
    DW .falling3
    DW .falling4
    DW .falling5
    DW .falling6
    DW .falling7
    DW .falling8
    
    ; Nothing
    DW .nothing

.skating1
    ; Skater Dude
    DB 0, 0, $00, 0
    DB 0, 8, $02, 0
    DB 0, 16, $04, 0
    DB 16, 0, $12, 0
    DB 16, 8, $14, 0
    DB 16, 16, $16, 0
    ; Skateboard
    DB 24, 0, $5E, OAMF_PAL1
    DB 24, 8, $60, OAMF_PAL1
    DB 24, 16, $62, OAMF_PAL1
    DB METASPRITE_END
.skating2
    ; Skater Dude
    DB 0, 0, $00, 0
    DB 0, 8, $02, 0
    DB 0, 16, $04, 0
    DB 16, 0, $12, 0
    DB 16, 8, $14, 0
    DB 16, 16, $16, 0
    ; Skateboard
    DB 24, 0, $64, OAMF_PAL1
    DB 24, 8, $60, OAMF_PAL1
    DB 24, 16, $66, OAMF_PAL1
    DB METASPRITE_END
.skating3
    ; Skater Dude
    DB 0, 0, $06, 0
    DB 0, 8, $08, 0
    DB 0, 16, $0A, 0
    DB 16, 0, $18, 0
    DB 16, 8, $1A, 0
    DB 16, 16, $1C, 0
    ; Skateboard
    DB 24, 0, $68, OAMF_PAL1
    DB 24, 8, $60, OAMF_PAL1
    DB 24, 16, $6A, OAMF_PAL1
    DB METASPRITE_END
.skating4
    ; Skater Dude
    DB 0, 0, $06, 0
    DB 0, 8, $08, 0
    DB 0, 16, $0A, 0
    DB 16, 0, $18, 0
    DB 16, 8, $1A, 0
    DB 16, 16, $1C, 0
    ; Skateboard
    DB 24, 0, $6C, OAMF_PAL1
    DB 24, 8, $60, OAMF_PAL1
    DB 24, 16, $6E, OAMF_PAL1
    DB METASPRITE_END

.jumping1
    ; Skater Dude
    DB 0, 0, $0C, 0
    DB 0, 8, $0E, 0
    DB 0, 16, $10, 0
    DB 16, 0, $1E, 0
    DB 16, 8, $20, 0
    DB 16, 16, $22, 0
    ; Skateboard
    DB 24, 0, $5E, OAMF_PAL1
    DB 24, 8, $60, OAMF_PAL1
    DB 24, 16, $62, OAMF_PAL1
    DB METASPRITE_END
.jumping2
    ; Skater Dude
    DB 0, 0, $24, 0
    DB 0, 8, $26, 0
    DB 0, 16, $28, 0
    DB 16, 0, $36, 0
    DB 16, 8, $38, 0
    DB 16, 16, $3A, 0
    ; Skateboard
    DB 24, 0, $64, OAMF_PAL1
    DB 24, 8, $60, OAMF_PAL1
    DB 24, 16, $66, OAMF_PAL1
    DB METASPRITE_END
.jumping3
    ; Skater Dude
    DB 0, 0, $2A, 0
    DB 0, 8, $2C, 0
    DB 0, 16, $2E, 0
    DB 16, 0, $3C, 0
    DB 16, 8, $3E, 0
    DB 16, 16, $40, 0
    ; Skateboard
    DB 24, 0, $68, OAMF_PAL1
    DB 24, 8, $60, OAMF_PAL1
    DB 24, 16, $6A, OAMF_PAL1
    DB METASPRITE_END
.jumping4
    ; Skater Dude
    DB 0, 0, $2A, 0
    DB 0, 8, $2C, 0
    DB 0, 16, $2E, 0
    DB 16, 0, $3C, 0
    DB 16, 8, $3E, 0
    DB 16, 16, $40, 0
    ; Skateboard
    DB 23, 0, $7E, OAMF_PAL1
    DB 23, 8, $72, OAMF_PAL1
    DB 23, 16, $80, OAMF_PAL1
    DB METASPRITE_END
.jumping5
    ; Skater Dude
    DB 0, 0, $2A, 0
    DB 0, 8, $2C, 0
    DB 0, 16, $2E, 0
    DB 16, 0, $3C, 0
    DB 16, 8, $3E, 0
    DB 16, 16, $40, 0
    ; Skateboard
    DB 24, 0, $70, OAMF_PAL1
    DB 24, 8, $72, OAMF_PAL1
    DB 24, 16, $74, OAMF_PAL1
    DB METASPRITE_END
.jumping6
    ; Skater Dude
    DB 0, 0, $2A, 0
    DB 0, 8, $2C, 0
    DB 0, 16, $2E, 0
    DB 16, 0, $3C, 0
    DB 16, 8, $3E, 0
    DB 16, 16, $40, 0
    ; Skateboard
    DB 28, 0, $76, OAMF_PAL1
    DB 28, 8, $72, OAMF_PAL1
    DB 28, 16, $78, OAMF_PAL1
    DB METASPRITE_END
.jumping7
    ; Skater Dude
    DB 0, 0, $2A, 0
    DB 0, 8, $2C, 0
    DB 0, 16, $2E, 0
    DB 16, 0, $3C, 0
    DB 16, 8, $3E, 0
    DB 16, 16, $40, 0
    ; Skateboard
    DB 30, 0, $7A, OAMF_PAL1
    DB 30, 8, $72, OAMF_PAL1
    DB 30, 16, $7C, OAMF_PAL1
    DB METASPRITE_END

.falling1
    ; Skater Dude
    DB 0, 0, $00, 0
    DB 0, 8, $02, 0
    DB 0, 16, $04, 0
    DB 16, 0, $12, 0
    DB 16, 8, $14, 0
    DB 16, 16, $16, 0
    ; Skateboard
    DB 24, 8, $5E, OAMF_PAL1
    DB 24, 16, $60, OAMF_PAL1
    DB 24, 24, $62, OAMF_PAL1
    DB METASPRITE_END
.falling2
    ; Skater Dude
    DB 0, 0, $48, 0
    DB 0, 8, $4A, 0
    DB 0, 16, $4C, 0
    DB 16, 0, $4E, 0
    DB 16, 8, $50, 0
    DB 16, 16, $52, 0
    ; Skateboard
    DB 24, 16, $88, OAMF_PAL1
    DB 24, 24, $84, OAMF_PAL1
    DB 24, 32, $8A, OAMF_PAL1
    DB METASPRITE_END
.falling3
    ; Skater Dude
    DB 0, 0, $48, 0
    DB 0, 8, $4A, 0
    DB 0, 16, $4C, 0
    DB 16, 0, $4E, 0
    DB 16, 8, $50, 0
    DB 16, 16, $52, 0
    ; Skateboard
    DB 13, 24, $94, OAMF_PAL1
    DB 9, 31, $96, OAMF_PAL1
    DB METASPRITE_END
.falling4
    ; Skater Dude
    DB 0, 0, $48, 0
    DB 0, 8, $4A, 0
    DB 0, 16, $4C, 0
    DB 16, 0, $4E, 0
    DB 16, 8, $50, 0
    DB 16, 16, $52, 0
    ; Skateboard
    DB 19, 31, $94, OAMF_PAL1
    DB 15, 38, $96, OAMF_PAL1
    DB METASPRITE_END
.falling5
    ; Skater Dude
    DB 16, 0, $54, 0
    DB 16, 8, $56, 0
    DB 16, 16, $58, 0
    DB 16, 24, $5A, 0
    DB 16, 32, $5C, 0
    ; Skateboard
    DB 11, 49, $94, OAMF_PAL1
    DB 7, 56, $96, OAMF_PAL1
    DB METASPRITE_END
.falling6
    ; Skater Dude
    DB 16, 0, $54, 0
    DB 16, 8, $56, 0
    DB 16, 16, $58, 0
    DB 16, 24, $5A, 0
    DB 16, 32, $5C, 0
    ; Skateboard
    DB 19, 51, $76, OAMF_PAL1
    DB 19, 59, $72, OAMF_PAL1
    DB 19, 67, $78, OAMF_PAL1
    DB METASPRITE_END
.falling7
    ; Skater Dude
    DB 16, 0, $54, 0
    DB 16, 8, $56, 0
    DB 16, 16, $58, 0
    DB 16, 24, $5A, 0
    DB 16, 32, $5C, 0
    ; Skateboard
    DB 19, 60, $76, OAMF_PAL1
    DB 19, 68, $72, OAMF_PAL1
    DB 19, 76, $78, OAMF_PAL1
    DB METASPRITE_END
.falling8
    ; Skater Dude
    DB 16, 0, $54, 0
    DB 16, 8, $56, 0
    DB 16, 16, $58, 0
    DB 16, 24, $5A, 0
    DB 16, 32, $5C, 0
    DB METASPRITE_END

.nothing
    DB METASPRITE_END
