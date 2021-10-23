# Attribution
## SoundSystem
Files:
- [code/SoundSystem.asm](/code/SoundSystem.asm), originally [Driver/SoundSystem.asm](https://github.com/gb-archive/GBSoundSystem/blob/a8468d766b1f32fa31ab206f291bc71d3c5b133e/Driver/SoundSystem.asm)
- [constants/SoundSystem.def](/constants/SoundSystem.def), originally [Driver/SoundSystem.def](https://github.com/gb-archive/GBSoundSystem/blob/a8468d766b1f32fa31ab206f291bc71d3c5b133e/Driver/SoundSystem.def)
- [constants/SoundSystem.inc](/constants/SoundSystem.inc), originally [Driver/SoundSystem.inc](https://github.com/gb-archive/GBSoundSystem/blob/a8468d766b1f32fa31ab206f291bc71d3c5b133e/Driver/SoundSystem.inc)
- [constants/SoundSystemNotes.inc](/constants/SoundSystemNotes.inc), originally [Driver/SoundSystemNotes.inc](https://github.com/gb-archive/GBSoundSystem/blob/a8468d766b1f32fa31ab206f291bc71d3c5b133e/Driver/SoundSystemNotes.inc)
- [code/jukebox.asm](/code/jukebox.asm), originally [Example/Example.asm](https://github.com/gb-archive/GBSoundSystem/blob/a8468d766b1f32fa31ab206f291bc71d3c5b133e/Example/Example.asm)
- [data/jukebox-font.bin](/data/jukebox-font.bin), originally [Example/font.bin](https://github.com/gb-archive/GBSoundSystem/blob/a8468d766b1f32fa31ab206f291bc71d3c5b133e/Example/font.bin)

The files listed above are originally from Bob Koon's [SoundSystem
Driver][soundsystem]. It is licensed under [the MIT License][ss-license].
Note, however, that [SoundSystem.asm](/code/SoundSystem.asm) has been
modified from the original to work better with Rhythm Land, and
[SoundSystem.def](/constants/SoundSystem.def) contains driver
configuration specifically for Rhythm Land. [jukebox.asm](/code/jukebox.asm)
has also been modified to use in the game.

<!-- [soundsystem]: https://github.com/BlitterObjectBob/GBSoundSystem/tree/a8468d766b1f32fa31ab206f291bc71d3c5b133e -->
[soundsystem]: https://github.com/gb-archive/GBSoundSystem/tree/a8468d766b1f32fa31ab206f291bc71d3c5b133e
<!-- [ss-license]: https://github.com/BlitterObjectBob/GBSoundSystem/blob/a8468d766b1f32fa31ab206f291bc71d3c5b133e/LICENSE -->
[ss-license]: https://github.com/gb-archive/GBSoundSystem/blob/a8468d766b1f32fa31ab206f291bc71d3c5b133e/LICENSE

## gb-vwf
Files:
- [code/vwf.asm](/code/vwf.asm), originally [vwf.asm](https://github.com/ISSOtm/gb-vwf/blob/08c9305b1a2455b30e8441198fa42581f39ea880/vwf.asm)
- [tools/make_font.py](/tools/make_font.py), originally [make_font.py](https://github.com/ISSOtm/gb-vwf/blob/08c9305b1a2455b30e8441198fa42581f39ea880/make_font.py)

The files listed above are from Eldred Habert's [gb-vwf text
engine][gb-vwf]. It is licensed under [the MIT License][vwf-license].

[gb-vwf]: https://github.com/ISSOtm/gb-vwf/tree/08c9305b1a2455b30e8441198fa42581f39ea880
[vwf-license]: https://github.com/ISSOtm/gb-vwf/blob/08c9305b1a2455b30e8441198fa42581f39ea880/LICENSE

## `CalcPercentDigit`
Found in [code/rating.asm](/code/rating.asm). From *Libbet*'s
[src/bcd.z80][bcd], originally called `pctdigit`.

Original code from Damian Yerrick's [*Libbet and the Magic Floor*][libbet].
It is licensed under [the zlib License][libbet-license].

[libbet]: https://github.com/pinobatch/libbet/tree/41ba11276a616a89975902d625e94f6ce5feb484
[libbet-license]: https://github.com/pinobatch/libbet/blob/41ba11276a616a89975902d625e94f6ce5feb484/LICENSE
[bcd]: https://github.com/pinobatch/libbet/blob/41ba11276a616a89975902d625e94f6ce5feb484/src/bcd.z80#L51-L95

## `Multiply`
Found in [code/utils.asm](/code/utils.asm). From *µCity*'s
[source/engine/utils.asm][mul], originally called `mul_u8u8u16`.

Original code from Antonio Niño Díaz's [*µCity*][ucity].
It is licensed under [version 3 of the GNU General Public License][ucity-license].

[ucity]: https://github.com/AntonioND/ucity/tree/15be184b26b337110e1ec2998cd42f134f00f281
[ucity-license]: https://github.com/AntonioND/ucity/blob/15be184b26b337110e1ec2998cd42f134f00f281/gpl-3.0.txt
[mul]: https://github.com/AntonioND/ucity/blob/15be184b26b337110e1ec2998cd42f134f00f281/source/engine/utils.asm#L137-L161
