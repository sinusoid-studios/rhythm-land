INCLUDE "defines.inc"

SECTION "Actor Subroutine Table", ROM0

ActorRoutineTable::
    full_pointer xActorSkaterDude   ; ACTOR_SKATER_DUDE
.end::

SECTION "Actor Animation Table", ROM0

ActorAnimationTable::
    full_pointer xActorSkaterDudeAnimation  ; ACTOR_SKATER_DUDE
.end::

SECTION "Actor Meta-Sprite Table", ROM0

ActorMetaspriteTable::
    full_pointer xActorSkaterDudeMetasprites    ; ACTOR_SKATER_DUDE
.end::
