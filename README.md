# Rhythm Land
A Rhythm Heaven-esque rhythm game for the Nintendo Game Boy

Made for [GB Compo 21](https://itch.io/jam/gbcompo21)

## Building
Requirements:
- [RGBDS][rgbds] v0.5.1 or later
- [SuperFamiconv][superfamiconv] `f4b4254` or later
- [Python 3][python3] and [Pillow][pillow]
- [GNU Make][make]

[rgbds]: https://github.com/gbdev/rgbds
[superfamiconv]: https://github.com/Optiroc/SuperFamiconv
[python3]: https://www.python.org
[pillow]: https://python-pillow.org
[make]: https://www.gnu.org/software/make

Run `make` in the root directory of the repository to produce the `bin`
directory, containing `rhythm-land.gb` along with its map and symbol
files.

Run `make soundtest` to build the sound test ROM containing all music
and sound effects, or `make all` to build both the game and the
soundtest at the same time.

## Attribution
### SoundSystem
Files:
- [code/SoundSystem.asm](/code/SoundSystem.asm)
- [constants/SoundSystem.def](/constants/SoundSystem.def)
- [constants/SoundSystem.inc](/constants/SoundSystem.inc)
- [constants/SoundSystemNotes.inc](/constants/SoundSystemNotes.inc)
- [soundtest/soundtest.asm](/soundtest/soundtest.asm)
- [soundtest/font.bin](/soundtest/font.bin)

The files listed above are originally from Bob Koon's [SoundSystem
Driver][soundsystem-versionused]. It is licensed under the MIT License, a copy of
which can be found in [LICENSE.SoundSystem](/LICENSE.SoundSystem). Note,
however, that [SoundSystem.asm](/code/SoundSystem.asm) has been modified
from the original to work better with Rhythm Land, and
[SoundSystem.def](/constants/SoundSystem.def) contains driver
configuration specifically for Rhythm Land.

[soundsystem-versionused]: https://github.com/BlitterObjectBob/GBSoundSystem/tree/a8468d766b1f32fa31ab206f291bc71d3c5b133e

### gb-vwf
Files:
- [code/vwf.asm](/code/vwf.asm)
- [tools/make_font.py](/tools/make_font.py)

The files listed above are from Eldred Habert's [gb-vwf text
engine][gb-vwf-versionused]. It is licensed under the MIT License, a copy of which
can be found in [LICENSE.gb-vwf](/LICENSE.gb-vwf).

[gb-vwf-versionused]: https://github.com/ISSOtm/gb-vwf/tree/08c9305b1a2455b30e8441198fa42581f39ea880

## Credits
- [martendo][martendo] &mdash; Programming, Music &amp; SFX
- [eat_butt_loser_butt][eat_butt_loser_butt] &mdash; Art, Design
- [St&eacute;phane Hockenhull][rv6502] &mdash; [Game Boy Tracker][gb-tracker]
- [Bob Koon (BlitterObject)][blitterobject] &mdash; [SoundSystem sound driver][soundsystem]
- [Eldred Habert (ISSOtm)][issotm] &mdash; [gb-vwf text engine][gb-vwf]

[martendo]: https://github.com/martendo
[eat_butt_loser_butt]: https://github.com/Eat-butt-loser-butt
[rv6502]: https://rv6502.ca
[blitterobject]: https://github.com/BlitterObjectBob
[issotm]: https://eldred.fr
[gb-tracker]: https://rv6502.ca/wiki/index.php?title=Game_Boy_Tracker
[soundsystem]: https://github.com/BlitterObjectBob/GBSoundSystem
[gb-vwf]: https://github.com/ISSOtm/gb-vwf
