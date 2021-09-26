INCLUDE "constants/hardware.inc"
INCLUDE "constants/actors.inc"
INCLUDE "macros/actors.inc"

SECTION "Battleship Boat Actor Animation Data", ROMX

xActorBoatAnimation::
    animation Boat, BOAT

.left
    cel enter1, 4
    cel enter2, 4
    cel enter3, 4
    cel enter4, 4
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
    cel enter1, 4
    cel enter2, 4
    cel enter3, 4
    cel enter4, 4
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
    obj 16, 8, $46, OAMF_PAL1
    obj 16, 16, $48, OAMF_PAL1
    obj 16, 24, $4A, OAMF_PAL1
    obj 0, 16, $4C, OAMF_PAL1
    obj 0, 24, $4E, OAMF_PAL1
    obj 1, 25, $9E, OAMF_PAL1
    DB METASPRITE_END
.left2
    obj 16, 8, $50, OAMF_PAL1
    obj 16, 16, $52, OAMF_PAL1
    obj 16, 24, $54, OAMF_PAL1
    obj 16, 32, $56, OAMF_PAL1
    obj 0, 18, $58, OAMF_PAL1
    obj 0, 26, $5A, OAMF_PAL1
    obj 6, 32, $A0, OAMF_PAL1
    DB METASPRITE_END
.exitLeft1
    obj 16, 8, $5C, OAMF_PAL1
    obj 16, 16, $5E, OAMF_PAL1
    obj 16, 24, $60, OAMF_PAL1
    obj 15, 32, $62, OAMF_PAL1
    obj 0, 24, $64, OAMF_PAL1
    obj 0, 16, $66, OAMF_PAL1
    obj 9, 37, $A2, OAMF_PAL1
    DB METASPRITE_END
.exitLeft2
    obj 16, 8, $5C, OAMF_PAL1
    obj 16, 16, $5E, OAMF_PAL1
    obj 16, 24, $60, OAMF_PAL1
    obj 0, 24, $64, OAMF_PAL1
    obj 15, 32, $62, OAMF_PAL1
    obj 0, 16, $66, OAMF_PAL1
    obj 9, 37, $A4, OAMF_PAL1
    DB METASPRITE_END
.exitLeft3
    obj 16, 8, $68, OAMF_PAL1
    obj 16, 16, $6A, OAMF_PAL1
    obj 14, 24, $6C, OAMF_PAL1
    obj 15, 32, $6E, OAMF_PAL1
    obj 0, 16, $66, OAMF_PAL1
    obj 0, 24, $64, OAMF_PAL1
    obj 9, 37, $A2, OAMF_PAL1
    DB METASPRITE_END
.exitLeft4
    obj 16, 8, $68, OAMF_PAL1
    obj 16, 16, $6A, OAMF_PAL1
    obj 14, 24, $6C, OAMF_PAL1
    obj 15, 32, $6E, OAMF_PAL1
    obj 0, 16, $66, OAMF_PAL1
    obj 0, 24, $64, OAMF_PAL1
    obj 9, 37, $A4, OAMF_PAL1
    DB METASPRITE_END
.right1
    obj 16, 32, $70, OAMF_PAL1
    obj 16, 16, $72, OAMF_PAL1
    obj 16, 24, $74, OAMF_PAL1
    obj 0, 16, $76, OAMF_PAL1
    obj 0, 24, $78, OAMF_PAL1
    obj 1, 15, $A6, OAMF_PAL1
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
    obj 15, 8, $86, OAMF_PAL1
    obj 16, 16, $88, OAMF_PAL1
    obj 16, 24, $8A, OAMF_PAL1
    obj 16, 32, $8C, OAMF_PAL1
    obj 0, 16, $8E, OAMF_PAL1
    obj 8, 4, $AA, OAMF_PAL1
    DB METASPRITE_END
.exitRight2
    obj 15, 8, $86, OAMF_PAL1
    obj 16, 16, $88, OAMF_PAL1
    obj 16, 24, $8A, OAMF_PAL1
    obj 16, 32, $8C, OAMF_PAL1
    obj 0, 16, $8E, OAMF_PAL1
    obj 0, 24, $90, OAMF_PAL1
    obj 9, 3, $AC, OAMF_PAL1
    DB METASPRITE_END
.exitRight3
    obj 15, 8, $92, OAMF_PAL1
    obj 16, 16, $94, OAMF_PAL1
    obj 16, 24, $96, OAMF_PAL1
    obj 16, 32, $98, OAMF_PAL1
    obj 0, 16, $8E, OAMF_PAL1
    obj 0, 24, $90, OAMF_PAL1
    obj 9, 3, $AA, OAMF_PAL1
    DB METASPRITE_END
.exitRight4
    obj 15, 8, $92, OAMF_PAL1
    obj 16, 16, $94, OAMF_PAL1
    obj 16, 24, $96, OAMF_PAL1
    obj 16, 32, $98, OAMF_PAL1
    obj 0, 16, $8E, OAMF_PAL1
    obj 0, 24, $90, OAMF_PAL1
    obj 9, 3, $AC, OAMF_PAL1
    DB METASPRITE_END
