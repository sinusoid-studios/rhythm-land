INCLUDE "macros/misc.inc"

SECTION "Actor Subroutine Table", ROM0

ActorRoutineTable::
    full_pointer xActorSkaterDude   ; ACTOR_SKATER_DUDE
    full_pointer Null   ; ACTOR_DANGER_ALERT
    full_pointer xActorObstacle ; ACTOR_CAR
    full_pointer xActorObstacle ; ACTOR_LOG
    full_pointer xActorObstacle ; ACTOR_OIL_BARREL
    full_pointer xActorTitle    ; ACTOR_LARGE_STAR_1
    full_pointer xActorTitle    ; ACTOR_LARGE_STAR_2
    full_pointer xActorTitle    ; ACTOR_LARGE_STAR_3
    full_pointer xActorTitle    ; ACTOR_LARGE_STAR_4
    full_pointer xActorTitle    ; ACTOR_SMALL_STAR_1
    full_pointer xActorTitle    ; ACTOR_SMALL_STAR_2
    full_pointer xActorTitle    ; ACTOR_SMALL_STAR_3
    full_pointer xActorTitle    ; ACTOR_SMALL_STAR_4
    full_pointer xActorTitle    ; ACTOR_SMALL_STAR_5
    full_pointer xActorTitle    ; ACTOR_SMALL_STAR_6
    full_pointer xActorTitle    ; ACTOR_SMALL_STAR_7
    full_pointer xActorSeagull  ; ACTOR_SEAGULL_1
    full_pointer xActorSeagull  ; ACTOR_SEAGULL_2
    full_pointer xActorSeagullPlayer    ; ACTOR_SEAGULL_3
    full_pointer xActorPancake  ; ACTOR_LARGE_PANCAKE
    full_pointer xActorPancake  ; ACTOR_SMALL_PANCAKE
    full_pointer Null   ; ACTOR_CURSOR
    full_pointer Null   ; ACTOR_SHIP
    full_pointer Null   ; ACTOR_SHIP_CANNON
    full_pointer Null   ; ACTOR_PROJECTILE
    full_pointer xActorBoatLeft ; ACTOR_BOAT_LEFT
    full_pointer xActorBoatRight    ; ACTOR_BOAT_RIGHT
    full_pointer Null   ; ACTOR_BOAT
    full_pointer Null   ; ACTOR_SMALL_EXPLOSION
.end::

SECTION "Actor Animation Table", ROM0

ActorAnimationTable::
    full_pointer xActorSkaterDudeAnimation  ; ACTOR_SKATER_DUDE
    full_pointer xActorDangerAlertAnimation ; ACTOR_DANGER_ALERT
    full_pointer xActorObstacleAnimation    ; ACTOR_CAR
    full_pointer xActorObstacleAnimation    ; ACTOR_LOG
    full_pointer xActorObstacleAnimation    ; ACTOR_OIL_BARREL
    full_pointer xActorLargeStar1Animation  ; ACTOR_LARGE_STAR_1
    full_pointer xActorLargeStar2Animation  ; ACTOR_LARGE_STAR_2
    full_pointer xActorLargeStar3Animation  ; ACTOR_LARGE_STAR_3
    full_pointer xActorLargeStar4Animation  ; ACTOR_LARGE_STAR_4
    full_pointer xActorSmallStar1Animation  ; ACTOR_SMALL_STAR_1
    full_pointer xActorSmallStar2Animation  ; ACTOR_SMALL_STAR_2
    full_pointer xActorSmallStar3Animation  ; ACTOR_SMALL_STAR_3
    full_pointer xActorSmallStar4Animation  ; ACTOR_SMALL_STAR_4
    full_pointer xActorSmallStar5Animation  ; ACTOR_SMALL_STAR_5
    full_pointer xActorSmallStar6Animation  ; ACTOR_SMALL_STAR_6
    full_pointer xActorSmallStar7Animation  ; ACTOR_SMALL_STAR_7
    full_pointer xActorSeagull1Animation    ; ACTOR_SEAGULL_1
    full_pointer xActorSeagull2Animation    ; ACTOR_SEAGULL_2
    full_pointer xActorSeagull3Animation    ; ACTOR_SEAGULL_3
    full_pointer xActorLargePancakeAnimation    ; ACTOR_LARGE_PANCAKE
    full_pointer xActorSmallPancakeAnimation    ; ACTOR_SMALL_PANCAKE
    full_pointer xActorCursorAnimation  ; ACTOR_CURSOR
    full_pointer xActorShipAnimation    ; ACTOR_SHIP
    full_pointer xActorShipCannonAnimation  ; ACTOR_SHIP_CANNON
    full_pointer xActorProjectileAnimation  ; ACTOR_PROJECTILE
    full_pointer xActorBoatAnimation    ; ACTOR_BOAT_LEFT
    full_pointer xActorBoatAnimation    ; ACTOR_BOAT_RIGHT
    full_pointer xActorSmallExplosionAnimation  ; ACTOR_SMALL_EXPLOSION
.end::

SECTION "Actor Meta-Sprite Table", ROM0

ActorMetaspriteTable::
    full_pointer xActorSkaterDudeMetasprites    ; ACTOR_SKATER_DUDE
    full_pointer xActorDangerAlertMetasprites   ; ACTOR_DANGER_ALERT
    full_pointer xActorCarMetasprites   ; ACTOR_CAR
    full_pointer xActorLogMetasprites   ; ACTOR_LOG
    full_pointer xActorOilBarrelMetasprites ; ACTOR_OIL_BARREL
    full_pointer xActorLargeStar1Metasprites    ; ACTOR_LARGE_STAR_1
    full_pointer xActorLargeStar2Metasprites    ; ACTOR_LARGE_STAR_2
    full_pointer xActorLargeStar3Metasprites    ; ACTOR_LARGE_STAR_3
    full_pointer xActorLargeStar4Metasprites    ; ACTOR_LARGE_STAR_4
    full_pointer xActorSmallStar1Metasprites    ; ACTOR_SMALL_STAR_1
    full_pointer xActorSmallStar2Metasprites    ; ACTOR_SMALL_STAR_2
    full_pointer xActorSmallStar3Metasprites    ; ACTOR_SMALL_STAR_3
    full_pointer xActorSmallStar4Metasprites    ; ACTOR_SMALL_STAR_4
    full_pointer xActorSmallStar5Metasprites    ; ACTOR_SMALL_STAR_5
    full_pointer xActorSmallStar6Metasprites    ; ACTOR_SMALL_STAR_6
    full_pointer xActorSmallStar7Metasprites    ; ACTOR_SMALL_STAR_7
    full_pointer xActorSeagull1Metasprites  ; ACTOR_SEAGULL_1
    full_pointer xActorSeagull2Metasprites  ; ACTOR_SEAGULL_2
    full_pointer xActorSeagull3Metasprites  ; ACTOR_SEAGULL_3
    full_pointer xActorLargePancakeMetasprites  ; ACTOR_LARGE_PANCAKE
    full_pointer xActorSmallPancakeMetasprites  ; ACTOR_SMALL_PANCAKE
    full_pointer xActorCursorMetasprites    ; ACTOR_CURSOR
    full_pointer xActorShipMetasprites  ; ACTOR_SHIP
    full_pointer xActorShipCannonMetasprites    ; ACTOR_SHIP_CANNON
    full_pointer xActorProjectileMetasprites    ; ACTOR_PROJECTILE
    full_pointer xActorBoatMetasprites  ; ACTOR_BOAT_LEFT
    full_pointer xActorBoatMetasprites  ; ACTOR_BOAT_RIGHT
    full_pointer xActorSmallExplosionMetasprites    ; ACTOR_SMALL_EXPLOSION
.end::
