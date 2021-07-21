# Hit Tables
Each file in this directory contains a table of hits for its
corresponding game. A hit is a point in time where the player is
expected to press or release one or more keys, and how far off that time
the player actually does press or release those keys determines how well
they do.

## Table Format
The first byte of the table contains the hit keys of the game, or all of
the keys used in hits in the game. If the game uses release hits, the
release hit bit must be set (see "Hit Keys" below).

Each entry in the table consists of 2 items, totalling 3 bytes:
1. Number of frames this hit comes after the previous, -1 signalling the
end of the table. 2 bytes.
2. Keys that the player must press for this hit. 1 byte.

## Hit Keys
Hit key bytes are just bitfields for the keys that should be pressed,
using the `hardware.inc` constants (`PADF_*`). However, one of those
bits is special: the bit that would normally represent the START button
instead makes a hit a *release hit*, meaning the hit keys should be
*released* for a hit.

START was chosen simply because it should never be used as a hit key as
it's reserved for pausing or resuming a game.
