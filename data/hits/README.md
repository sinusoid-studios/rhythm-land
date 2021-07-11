# Hit Tables
Each file in this directory contains a table of hits for its
corresponding game. A hit is a point in time where the player is
expected to press one or more keys, and how far off that time the player
actually does press those keys determines how well they do.

## Table Format
Each entry in the table consists of 2 bytes:
1. Number of frames this hit comes after the previous, -1 signalling the
end of the table.
2. Keys that the player must press for this hit.
