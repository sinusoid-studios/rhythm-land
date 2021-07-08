# Cue Tables
Each file in this directory contains a table of cues for its
corresponding game. A cue can be anything the game decides &mdash; it's
just a subroutine that's called by the engine when it's time.

## Table Format
Each entry in the table consists of 2 bytes:
1. Number of frames this cue comes after the previous, -1 signalling the
end of the table.
2. The ID of the cue, to be used in a jumptable of subroutines.
