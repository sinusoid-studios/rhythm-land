INCLUDE "defines.inc"

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
.end::

SECTION "Actor Animation Table", ROM0

ActorAnimationTable::
    full_pointer xActorSkaterDudeAnimation  ; ACTOR_SKATER_DUDE
    full_pointer xActorDangerAlertAnimation ; ACTOR_DANGER_ALERT
    full_pointer xActorCarAnimation ; ACTOR_CAR
    full_pointer xActorLogAnimation ; ACTOR_LOG
    full_pointer xActorOilBarrelAnimation   ; ACTOR_OIL_BARREL
    full_pointer xActorLargeStar1Animation  ; ACTOR_LARGE_STAR_1
    full_pointer xActorLargeStar2Animation  ; ACTOR_LARGE_STAR_2
    full_pointer xActorLargeStar3Animation  ; ACTOR_LARGE_STAR_3
    full_pointer xActorLargeStar4Animation  ; ACTOR_LARGE_STAR_4
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
.end::
