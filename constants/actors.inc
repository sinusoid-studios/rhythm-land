; Number of spots to put in the actor tables
DEF MAX_ACTOR_COUNT EQU 11

; Number of tiles to give each actor for tile streaming
DEF ACTOR_RESERVED_TILE_COUNT EQU 16

; Actor types
RSRESET
DEF ACTOR_SKATER_DUDE RB 1
DEF ACTOR_DANGER_ALERT RB 1
DEF ACTOR_OBSTACLES_START EQU _RS
DEF ACTOR_CAR RB 1
DEF ACTOR_LOG RB 1
DEF ACTOR_OIL_BARREL RB 1
DEF OBSTACLE_COUNT EQU _RS - ACTOR_OBSTACLES_START
DEF ACTOR_STARS_START EQU _RS
DEF ACTOR_LARGE_STAR_1 RB 1
DEF ACTOR_LARGE_STAR_2 RB 1
DEF ACTOR_LARGE_STAR_3 RB 1
DEF ACTOR_LARGE_STAR_4 RB 1
DEF ACTOR_SMALL_STAR_1 RB 1
DEF ACTOR_SMALL_STAR_2 RB 1
DEF ACTOR_SMALL_STAR_3 RB 1
DEF ACTOR_SMALL_STAR_4 RB 1
DEF ACTOR_SMALL_STAR_5 RB 1
DEF ACTOR_SMALL_STAR_6 RB 1
DEF ACTOR_SMALL_STAR_7 RB 1
DEF STAR_COUNT EQU _RS - ACTOR_STARS_START
DEF ACTOR_SEAGULLS_START EQU _RS
DEF ACTOR_SEAGULL_1 RB 1
DEF ACTOR_SEAGULL_2 RB 1
DEF ACTOR_SEAGULL_3 RB 1
DEF SEAGULL_COUNT EQU _RS - ACTOR_SEAGULLS_START
DEF ACTOR_LARGE_PANCAKE RB 1
DEF ACTOR_SMALL_PANCAKE RB 1
DEF ACTOR_CURSOR RB 1
DEF ACTOR_SHIP RB 1
DEF ACTOR_SHIP_CANNON RB 1
DEF ACTOR_PROJECTILE RB 1
DEF ACTOR_BOAT_LEFT RB 1
DEF ACTOR_BOAT_RIGHT RB 1
DEF ACTOR_SMALL_EXPLOSION RB 1
DEF ACTOR_COUNT EQU _RS

DEF ACTOR_EMPTY EQU -1

; Animation special values
RSSET $80
DEF ANIMATION_GOTO RB 1
DEF ANIMATION_KILL_ACTOR RB 1
DEF ANIMATION_OVERRIDE_END RB 1
DEF ANIMATION_SET_TILES RB 1
DEF ANIMATION_SPECIAL_VALUE_COUNT EQU _RS & ~$80

; Cel duration value that means the current cel never ends
DEF ANIMATION_DURATION_FOREVER EQU -1

; Used in wActorCelOverrideTable when no animation override is in effect
DEF ANIMATION_OVERRIDE_NONE EQU -1
; When an animation override ends, don't change any tiles
DEF ANIMATION_OVERRIDE_END_NO_TILES EQU -1

; Meta-sprite special values
DEF METASPRITE_END EQU -128
