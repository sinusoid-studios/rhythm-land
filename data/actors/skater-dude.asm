INCLUDE "defines.inc"

SECTION "Skater Dude Actor Animation Data", ROMX

xActorSkaterDudeAnimation::
    animation_def xActorSkaterDude

.skating
    cel skating1, MUSIC_SKATER_DUDE_SPEED
    cel skating2, MUSIC_SKATER_DUDE_SPEED
.skatingSkip
    cel skating3, MUSIC_SKATER_DUDE_SPEED
    cel skating4, MUSIC_SKATER_DUDE_SPEED
    goto_cel .skating

.jumping
    cel jumping1, 2
    cel jumping2, 2
    cel jumping3, 2
    cel jumping4, (MUSIC_SKATER_DUDE_SPEED * 4) - (2 * 3) - (5 * 3)
    cel jumping5, 5
    cel jumping6, 5
    cel jumping7, 5
    goto_cel .skatingSkip

.falling
    cel falling1, 4
    cel falling2, 4
    cel falling3, 4
    cel falling4, 4
    cel falling5, 4
    cel falling6, 4
    cel falling7, 4
    cel falling8, (MUSIC_SKATER_DUDE_SPEED * 4) - (4 * 7)
    cel nothing, MUSIC_SKATER_DUDE_SPEED * 1
    cel falling8, MUSIC_SKATER_DUDE_SPEED * 1
    cel nothing, MUSIC_SKATER_DUDE_SPEED * 1
    cel falling8, MUSIC_SKATER_DUDE_SPEED * 1
    goto_cel .skating

SECTION "Skater Dude Actor Meta-Sprite Data", ROMX

xActorSkaterDudeMetasprites::
    ; Skating
    metasprite .skating1
    metasprite .skating2
    metasprite .skating3
    metasprite .skating4
    
    ; Jumping
    metasprite .jumping1
    metasprite .jumping2
    metasprite .jumping3
    metasprite .jumping4
    metasprite .jumping5
    metasprite .jumping6
    metasprite .jumping7
    
    ; Falling
    metasprite .falling1
    metasprite .falling2
    metasprite .falling3
    metasprite .falling4
    metasprite .falling5
    metasprite .falling6
    metasprite .falling7
    metasprite .falling8
    
    ; Nothing
    metasprite .nothing

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
.nothing
    DB METASPRITE_END
