INCLUDE "defines.inc"

SECTION "Actor Subroutine Table", ROM0

ActorRoutineTable::
    full_pointer xActorSkaterDude   ; ACTOR_SKATER_DUDE
    full_pointer Null   ; ACTOR_DANGER_ALERT
    full_pointer Null   ; ACTOR_CAR
    full_pointer Null   ; ACTOR_LOG
    full_pointer Null   ; ACTOR_OIL_BARREL
.end::

SECTION "Actor Animation Table", ROM0

ActorAnimationTable::
    full_pointer xActorSkaterDudeAnimation  ; ACTOR_SKATER_DUDE
    full_pointer xActorDangerAlertAnimation ; ACTOR_DANGER_ALERT
    full_pointer xActorCarAnimation ; ACTOR_CAR
    full_pointer xActorLogAnimation ; ACTOR_LOG
    full_pointer xActorOilBarrelAnimation   ; ACTOR_OIL_BARREL
.end::

SECTION "Actor Meta-Sprite Table", ROM0

ActorMetaspriteTable::
    full_pointer xActorSkaterDudeMetasprites    ; ACTOR_SKATER_DUDE
    full_pointer xActorDangerAlertMetasprites   ; ACTOR_DANGER_ALERT
    full_pointer xActorCarMetasprites   ; ACTOR_CAR
    full_pointer xActorLogMetasprites   ; ACTOR_LOG
    full_pointer xActorOilBarrelMetasprites ; ACTOR_OIL_BARREL
.end::
