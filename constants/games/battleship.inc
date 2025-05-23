INCLUDE "constants/other-hardware.inc"

; Number of frames per tick in the theme
DEF MUSIC_BATTLESHIP_SPEED EQU 11

; Game palettes
DEF BATTLESHIP_BGP EQU %11_10_01_00
DEF BATTLESHIP_OBP0 EQU %10_01_00_00   ; Dark gray, Light gray, White
DEF BATTLESHIP_OBP1 EQU %11_01_00_00   ; Black, Light gray, White

; Number of tiles wide and high the repeating ocean background is
DEF BATTLESHIP_OCEAN_SIZE EQU 6

; Initial value for SCY
DEF BATTLESHIP_INITIAL_Y EQU BATTLESHIP_OCEAN_SIZE * 8

; Ship actor
DEF BATTLESHIP_SHIP_X EQU SCRN_X / 2 - 48 / 2
DEF BATTLESHIP_SHIP_Y EQU SCRN_Y - 48
DEF BATTLESHIP_CANNON_X EQU SCRN_X / 2 - 16 / 2
DEF BATTLESHIP_CANNON_Y EQU SCRN_Y - 17

; Projectiles
DEF PROJECTILE_X EQU SCRN_X / 2 - 16 / 2
DEF PROJECTILE_Y EQU BATTLESHIP_SHIP_Y + 16
DEF PROJECTILE_LEFT_SPEED_X EQU -7.0f
DEF PROJECTILE_RIGHT_SPEED_X EQU 7.0f
DEF PROJECTILE_SPEED_Y EQU -12.0f

; Boat actors
DEF BOAT_LEFT_X EQU 16
DEF BOAT_RIGHT_X EQU SCRN_X - 16 - 32
DEF BOAT_Y EQU -24

DEF BOAT_SPEED_X EQU 0
DEF BOAT_SPEED_Y EQU 2.0f

; Explosions
DEF EXPLOSION_LEFT_X EQU BOAT_LEFT_X
DEF EXPLOSION_RIGHT_X EQU BOAT_RIGHT_X
DEF EXPLOSION_Y EQU BOAT_Y + 64

; Cues
DEF BATTLESHIP_BOATB_LEFT EQU 0
DEF BATTLESHIP_BOATB_RIGHT EQU 1
