; The bit used in hit key bytes as a "release hit" marker, for deciding
; whether to use hNewKeys or hReleasedKeys as player input for this hit.
; Takes the START button's place since it should never be used as a hit
; key in any game as it's reserved for pausing/resuming.
DEF HITB_RELEASE EQU PADB_START
DEF HITF_RELEASE EQU 1 << HITB_RELEASE

; Marker of the end of a hit table
DEF HITS_END EQU -1
