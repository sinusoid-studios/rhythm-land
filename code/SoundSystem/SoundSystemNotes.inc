IF !DEF(SOUNDSYSTEMNOTES_INC)
SOUNDSYSTEMNOTES_INC	SET	1

;===============================
; Usage
;===============================
; SoundSystem supports 6 full octaves worth of note frequencies. The GameBoy
; can actually output more than that, but supporting those would create
; incomplete octaves, so it's generally not useful.
;
; Use these values when calling SFX_Play, but including this file in your
; project is optional.

RSRESET
; octave 2
C_2	RB	1
Db2	RB	0
C#2	RB	1
D_2	RB	1
Eb2	RB	0
D#2	RB	1
E_2	RB	1
F_2	RB	1
Gb2	RB	0
F#2	RB	1
G_2	RB	1
Ab2	RB	0
G#2	RB	1
A_2	RB	1
Bb2	RB	0
A#2	RB	1
B_2	RB	1

; octave 3
C_3	RB	1
Db3	RB	0
C#3	RB	1
D_3	RB	1
Eb3	RB	0
D#3	RB	1
E_3	RB	1
F_3	RB	1
Gb3	RB	0
F#3	RB	1
G_3	RB	1
Ab3	RB	0
G#3	RB	1
A_3	RB	1
Bb3	RB	0
A#3	RB	1
B_3	RB	1

; octave 4
MID_C	RB	0	; Middle C
C_4	RB	1
Db4	RB	0
C#4	RB	1
D_4	RB	1
Eb4	RB	0
D#4	RB	1
E_4	RB	1
F_4	RB	1
Gb4	RB	0
F#4	RB	1
G_4	RB	1
Ab4	RB	0
G#4	RB	1
A_4	RB	1
Bb4	RB	0
A#4	RB	1
B_4	RB	1

; octave 5
C_5	RB	1
Db5	RB	0
C#5	RB	1
D_5	RB	1
Eb5	RB	0
D#5	RB	1
E_5	RB	1
F_5	RB	1
Gb5	RB	0
F#5	RB	1
G_5	RB	1
Ab5	RB	0
G#5	RB	1
A_5	RB	1
Bb5	RB	0
A#5	RB	1
B_5	RB	1

; octave 6
C_6	RB	1
Db6	RB	0
C#6	RB	1
D_6	RB	1
Eb6	RB	0
D#6	RB	1
E_6	RB	1
F_6	RB	1
Gb6	RB	0
F#6	RB	1
G_6	RB	1
Ab6	RB	0
G#6	RB	1
A_6	RB	1
Bb6	RB	0
A#6	RB	1
B_6	RB	1

; octave 7
C_7	RB	1
Db7	RB	0
C#7	RB	1
D_7	RB	1
Eb7	RB	0
D#7	RB	1
E_7	RB	1
F_7	RB	1
Gb7	RB	0
F#7	RB	1
G_7	RB	1
Ab7	RB	0
G#7	RB	1
A_7	RB	1
Bb7	RB	0
A#7	RB	1
B_7	RB	1

NUM_NOTES	RB	0

; sanity checks
ASSERT	Db2 == C#2
ASSERT	MID_C == C_4
ASSERT	NUM_NOTES == 72	; 6 octaves, 12 notes each

ENDC	; SOUNDSYSTEMNOTES_INC
