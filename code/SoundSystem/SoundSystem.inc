IF !DEF(SOUNDSYSTEM_INC)
SOUNDSYSTEM_INC	SET	1

;===============================
; Usage
;===============================
; There are two main routines: SoundSystem_Init and SoundSystem_Process.
; SoundSystem_Init is called just once to initialize the system, and
; SoundSystem_Process needs to be called once a frame to drive the player.
;
; SoundSystem behavior and the features it has is controlled via the
; SoundSystem.def file. Based on the definitions there, SoundSystem will
; include/exclude features. Some options have trade-offs which are described
; in the template SoundSystem.def file provided in the release  materials.
;
; General Notes
; - To make SoundSystem as efficient as possible, it will not preserve any
; registers at the call sites. This means that it is up to you to preserve
; anything before making any SoundSystem call. It is perhaps safest/easiest
; to think that all registers are used and ROM/WRAM banks changed*.
;
; *depending on the definitions in SoundSystem.def


;===============================
; Main Driver Functions
;===============================

;-------------------------------
; SoundSystem_Init
;
; This prepares SoundSystem for use. It must be called before any other
; SoundSystem functions can be called.
;
; Arguments:
;    None
;
; Example:
;    call SoundSystem_Init


;-------------------------------
; SoundSystem_Process
;
; This is the 'heartbeat' of the driver so it should be called every frame.
; The exact time (in a VBlank or during a frame) isn't important; provided it
; is called at a regular interval.
;
; CPU usage is dependent on the audio SoundSystem is processing. Each effect
; has a cost and so the CPU time is not fixed.
;
; Notes:
; - Registers will not be preserved.
; - ROM/WRAM banks could change (based on SoundSystem.def settings).
;
; Arguments:
;    None
;
; Example:
;    ; preserve any registers, if applicable
;    call SoundSystem_Process
;    ; switch ROM bank, if applicable
;    ; switch WRAM bank, if applicable


;===============================
; Song (Music) Features
;===============================

;-------------------------------
; Music_PrepareInst
;
; In order for music to be playable with Music_Play (see below), it needs to
; be 'prepared' first. This routine tells SoundSystem where the instrument
; table resides, which can be in a different location where the actual music
; order table (pattern data) resides.
;
; Notes:
; - This needs to be called before every call to Music_Play.
; - The instrument table is part of the data that is exported by GB Tracker.
; Labeled as 'SFX Table' at the end of the exported data (the symbol starts
; with 'Inst_').
;
; Arguments:
;    BC - bank id where the instrument table resides
;    DE - pointer to the instrument table
;
; Example:
;    ld   bc,BANK(Inst_s11space)
;    ld   de,Inst_s11space
;    call Music_PrepareInst


;-------------------------------
; Music_Play
;
; This is the trigger to start music actually playing (and processed by
; SoundSystem_Process). The order table data can reside in a different
; location to the instrument data. SoundSystem will handle bank swapping
; as and when it needs to.
;
; Notes:
; - Music_PrepareInst needs to be called before this.
; - The music table is part of the data that is exported by GB Tracker.
; Labeled as 'Order Table' before the SFX data in the exported data.
;
; Arguments:
;    BC - bank id where the order table resides
;    DE - pointer to the order table
;
; Example:
;    ld   bc,BANK(Music_s11space)
;    ld   de,Music_s11space
;    call Music_Play


;-------------------------------
; Music_Pause
;
; This pauses music playback. After the music is paused, it is safe to
; call SoundSystem_Process and sound effects can still be triggered.
; Call Music_Resume (see below) to continue the music playback.
;
; Notes:
; - Subsequent calls to Music_Pause have no effect.
; - Calling Music_Pause before Music_Play has no effect, but best
; practice is to only call Music_Pause after Music_Play.
;
; Arguments:
;    None
;
; Example:
;    call Music_Pause


;-------------------------------
; Music_Resume
;
; This resumes music playback after Music_Pause (see above) has called.
;
; Notes:
; - Subsequent calls to Music_Resume have no effect, but best practice is to
; only call Music_Resume after Music_Pause.
;
; Arguments:
;    None
;
; Example:
;    call Music_Resume


;===============================
; Sound Effect (SFX) Features
;===============================

;-------------------------------
; SFX_Prepare
;
; In order for one-shot sound effects (SFX) to be playable with SFX_Play (see
; below), they need to be 'prepared' first. This routine tells SoundSystem
; where the sound effects table resides, which can be in a different location
; where the music data resides.
;
; Notes:
; - This needs to be called just once per 'set' of sound effects. Once called,
; any number of SFX_Play calls can be made.
; - Typically, sound effects are kept separate to any music data.
; - The sfx table is part of the data that is exported by GB Tracker.
; Commented as 'SFX Table' in the exported data (the symbol starts with 'SFX').
;
; Arguments:
;    BC - bank id where the sfx table resides
;    DE - pointer to the sfx table
;
; Example:
;    ld   bc,BANK(SFX_Table)
;    ld   de,SFX_Table
;    call SFX_Prepare


;-------------------------------
; SFX_Play
;
; This is the trigger to start a one-shot sound effect actually playing (and
; processed by SoundSystem_Process).
;
; Notes:
; - SFX_Prepare needs to be called before this.
; - The note will only take affect if the sound doesn't set a note in its
; start command.
;
; Arguments:
;    B - id (not byte offset) of the sound effect to play
;    C - note (frequency) at which to play the sound effect, 0-71
;        6 octaves of 12 notes: C_2 (0) to B_7 (71), middle C is C_4 (24)
;        See SoundSystemNotes.inc for specific values.
;
; Example:
;    ld   b,COOL_SFX_1
;    ld   c,C_4
;   ;ld   bc,(COOL_SFX_1<<8)|C_4    ; or this way as an optimization
;    call SFX_Play


;-------------------------------
; SFX_Stop
;
; This immediately terminates all one-shot sound effects from playing.
;
; Notes:
; - It is safe to call this multiple times or of SFX_Play hasn't been called.
;
; Arguments:
;    None
;
; Example:
;    call SFX_Stop


;-------------------------------
; SFX_LockChannel3
; SFX_UnlockChannel3
;
; This pair of routines affect the wave channel (channel 3) of the GameBoy.
; Locking the channel will prevent music and other sound effects from using
; that channel until it is unlocked again.
;
; Notes:
; - Subsequent calls to either SFX_LockChannel3 or SFX_UnlockChannel3 have no
; effect. Only the first call changes behavior.
; - Channel 3 is unlocked by default.
;
; Arguments:
;    None
;
; Example:
;    call SFX_LockChannel3
;    ...
;    call SFX_UnlockChannel3


;===============================
; Miscellaneous Features
;===============================

;-------------------------------
; Playback State
;
; You can check the playback state by inspecting wMusicPlayState. EQUates are
; provided below for possible values: either stopped or playing.
MUSIC_STATE_STOPPED	EQU	0
MUSIC_STATE_PLAYING	EQU	1

;-------------------------------
; Synchronization
;
; The tracker has a mechanism that provides a way to synchronize the code with
; the music via the Zxx Flag Command. This sends a value ($00-$FF) to the code
; to be processed however applicable (or ignored).
;
; wMusicSyncData
;
; Notes:
; - This is a raw value and not further processed by SoundSystem so it is
; entirely managed the musician.

;-------------------------------
; VU Meters
;
; SoundSystem can provide data that can drive a VU-meter type display. This is
; disabled by default, but access to that data is provided by setting
; SOUNDSYSTEM_ENABLE_VUM in SoundSystem.def to 1.
;
; If enabled, the data (value $0-$F) is in 4 1-byte variables, one per channel:
;     'wVUMeter1' = channel 1
;     'wVUMeter2' = channel 2
;     'wVUMeter3' = channel 3
;     'wVUMeter4' = channel 4
;
; They are contiguous in memory so you can access them as an array if needed.
;
; Notes:
; - CPU, code size, and RAM usage is slightly more if this is enabled.

;-------------------------------
; Identity
;
; There are two symbols that can be used for attribution:
;     SoundSystem_Version
;     SoundSystem_Author
;
; Notes:
; - These are NULL-terminated strings.


ENDC	; SOUNDSYSTEM_INC
