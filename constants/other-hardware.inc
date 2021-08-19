; Number of bytes to allocate for the stack
DEF STACK_SIZE EQU 24 * 2

; Hardware register flags and bit numbers
DEF STAT_MODE_MASK EQU %00000011
DEF LCDCB_WIN EQU 5
DEF STATB_LYC EQU 6
DEF IEB_STAT EQU 1

; Convert RGBASM Q16.16 fixed point to actor Q5.3 fixed point
DEF f EQUS " >> (16 - 3)"
