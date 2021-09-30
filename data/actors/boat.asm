INCLUDE "constants/hardware.inc"
INCLUDE "constants/actors.inc"
INCLUDE "constants/games/battleship.inc"
INCLUDE "macros/actors.inc"

SECTION "Battleship Boat Actor Animation Data", ROMX

xActorBoatAnimation::
    animation Boat, BOAT

.left
    cel enter1, MUSIC_BATTLESHIP_SPEED * 2 / 4
    cel enter2, MUSIC_BATTLESHIP_SPEED * 2 / 4
    cel enter3, MUSIC_BATTLESHIP_SPEED * 2 / 4
    cel enter4, MUSIC_BATTLESHIP_SPEED * 2 / 4
    cel left1, 4
    cel left2, 4
    cel exitLeft1, 4
    cel exitLeft2, 4
    cel exitLeft3, 4
    cel exitLeft4, 4
    DB ANIMATION_KILL_ACTOR

    ; Fix alignment
    DS 1
.right
    cel enter1, MUSIC_BATTLESHIP_SPEED * 2 / 4
    cel enter2, MUSIC_BATTLESHIP_SPEED * 2 / 4
    cel enter3, MUSIC_BATTLESHIP_SPEED * 2 / 4
    cel enter4, MUSIC_BATTLESHIP_SPEED * 2 / 4
    cel right1, 4
    cel right2, 4
    cel exitRight1, 4
    cel exitRight2, 4
    cel exitRight3, 4
    cel exitRight4, 4
    DB ANIMATION_KILL_ACTOR

    ; Cel constant definitions
    def_cel .left, LEFT
    def_cel .right, RIGHT

SECTION "Battleship Boat Actor Meta-Sprite Data", ROMX

xActorBoatMetasprites::
    metasprite .enter1
    metasprite .enter2
    metasprite .enter3
    metasprite .enter4
    metasprite .left1
    metasprite .left2
    metasprite .exitLeft1
    metasprite .exitLeft2
    metasprite .exitLeft3
    metasprite .exitLeft4
    metasprite .right1
    metasprite .right2
    metasprite .exitRight1
    metasprite .exitRight2
    metasprite .exitRight3
    metasprite .exitRight4

.enter1
    obj 8, 8, $36, OAMF_PAL1
    obj 8, 16, $38, OAMF_PAL1
    obj 24, 8, $3A, OAMF_PAL1
    obj 24, 16, $3C, OAMF_PAL1
    obj 4, 12, $9A, OAMF_PAL1
    DB METASPRITE_END
.enter2
    obj 8, 8, $36, OAMF_PAL1
    obj 8, 16, $38, OAMF_PAL1
    obj 24, 8, $3A, OAMF_PAL1
    obj 24, 16, $3C, OAMF_PAL1
    obj 4, 12, $9C, OAMF_PAL1
    DB METASPRITE_END
.enter3
    obj 8, 8, $3E, OAMF_PAL1
    obj 8, 16, $40, OAMF_PAL1
    obj 24, 8, $42, OAMF_PAL1
    obj 24, 16, $44, OAMF_PAL1
    obj 4, 12, $9A, OAMF_PAL1
    DB METASPRITE_END
.enter4
    obj 8, 8, $3E, OAMF_PAL1
    obj 8, 16, $40, OAMF_PAL1
    obj 24, 8, $42, OAMF_PAL1
    obj 24, 16, $44, OAMF_PAL1
    obj 4, 12, $9C, OAMF_PAL1
    DB METASPRITE_END
.left1
    obj 20, -2, $46, OAMF_PAL1
    obj 20, 6, $48, OAMF_PAL1
    obj 20, 14, $4A, OAMF_PAL1
    obj 4, 6, $4C, OAMF_PAL1
    obj 4, 14, $4E, OAMF_PAL1
    obj 5, 15, $9E, OAMF_PAL1
    DB METASPRITE_END
.left2
    obj 16, -10, $50, OAMF_PAL1
    obj 16, -2, $52, OAMF_PAL1
    obj 16, 6, $54, OAMF_PAL1
    obj 16, 14, $56, OAMF_PAL1
    obj 0, 0, $58, OAMF_PAL1
    obj 0, 8, $5A, OAMF_PAL1
    obj 6, 14, $A0, OAMF_PAL1
    DB METASPRITE_END
.exitLeft1
    obj 16, -18, $5C, OAMF_PAL1
    obj 16, -10, $5E, OAMF_PAL1
    obj 16, -2, $60, OAMF_PAL1
    obj 15, 6, $62, OAMF_PAL1
    obj 0, -2, $64, OAMF_PAL1
    obj 0, -10, $66, OAMF_PAL1
    obj 9, 11, $A2, OAMF_PAL1
    DB METASPRITE_END
.exitLeft2
    obj 16, -26, $5C, OAMF_PAL1
    obj 16, -18, $5E, OAMF_PAL1
    obj 16, -10, $60, OAMF_PAL1
    obj 0, -10, $64, OAMF_PAL1
    obj 15, -2, $62, OAMF_PAL1
    obj 0, -18, $66, OAMF_PAL1
    obj 9, 3, $A4, OAMF_PAL1
    DB METASPRITE_END
.exitLeft3
    obj 16, -34, $68, OAMF_PAL1
    obj 16, -26, $6A, OAMF_PAL1
    obj 14, -18, $6C, OAMF_PAL1
    obj 15, -10, $6E, OAMF_PAL1
    obj 0, -26, $66, OAMF_PAL1
    obj 0, -18, $64, OAMF_PAL1
    obj 9, -5, $A2, OAMF_PAL1
    DB METASPRITE_END
.exitLeft4
    obj 16, -42, $68, OAMF_PAL1
    obj 16, -34, $6A, OAMF_PAL1
    obj 14, -26, $6C, OAMF_PAL1
    obj 15, -18, $6E, OAMF_PAL1
    obj 0, -34, $66, OAMF_PAL1
    obj 0, -26, $64, OAMF_PAL1
    obj 9, -13, $A4, OAMF_PAL1
    DB METASPRITE_END
.right1
    obj 20, 26, $70, OAMF_PAL1
    obj 20, 10, $72, OAMF_PAL1
    obj 20, 18, $74, OAMF_PAL1
    obj 4, 10, $76, OAMF_PAL1
    obj 4, 18, $78, OAMF_PAL1
    obj 5, 9, $A6, OAMF_PAL1
    DB METASPRITE_END
.right2
    obj 16, 8, $7A, OAMF_PAL1
    obj 16, 16, $7C, OAMF_PAL1
    obj 16, 24, $7E, OAMF_PAL1
    obj 16, 32, $80, OAMF_PAL1
    obj 0, 16, $82, OAMF_PAL1
    obj 0, 24, $84, OAMF_PAL1
    obj 6, 9, $A6, OAMF_PAL1
    DB METASPRITE_END
.exitRight1
    obj 15, 16, $86, OAMF_PAL1
    obj 16, 24, $88, OAMF_PAL1
    obj 16, 32, $8A, OAMF_PAL1
    obj 16, 40, $8C, OAMF_PAL1
    obj 0, 24, $8E, OAMF_PAL1
    obj 8, 12, $AA, OAMF_PAL1
    DB METASPRITE_END
.exitRight2
    obj 15, 32, $86, OAMF_PAL1
    obj 16, 40, $88, OAMF_PAL1
    obj 16, 48, $8A, OAMF_PAL1
    obj 16, 56, $8C, OAMF_PAL1
    obj 0, 40, $8E, OAMF_PAL1
    obj 0, 48, $90, OAMF_PAL1
    obj 9, 27, $AC, OAMF_PAL1
    DB METASPRITE_END
.exitRight3
    obj 15, 40, $92, OAMF_PAL1
    obj 16, 48, $94, OAMF_PAL1
    obj 16, 56, $96, OAMF_PAL1
    obj 16, 64, $98, OAMF_PAL1
    obj 0, 48, $8E, OAMF_PAL1
    obj 0, 56, $90, OAMF_PAL1
    obj 9, 35, $AA, OAMF_PAL1
    DB METASPRITE_END
.exitRight4
    obj 15, 52, $92, OAMF_PAL1
    obj 16, 60, $94, OAMF_PAL1
    obj 16, 68, $96, OAMF_PAL1
    obj 16, 76, $98, OAMF_PAL1
    obj 0, 60, $8E, OAMF_PAL1
    obj 0, 68, $90, OAMF_PAL1
    obj 9, 47, $AC, OAMF_PAL1
    DB METASPRITE_END
