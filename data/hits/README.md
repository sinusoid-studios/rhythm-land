# Hit Tables
Each file in this directory contains a table of hits for its
corresponding game. A hit is a point in time where the player is
expected to press a button, and how far off that time the player
actually does press a button determines how well they do.

## Table Format
Each entry in the table consists of 1 byte:
1. Number of frames this hit comes after the previous, -1 signalling the end of the table
