# Rhythm Land
A Rhythm Heaven-esque rhythm game for the Nintendo Game Boy

Made for [GB Compo 21](https://itch.io/jam/gbcompo21)

## Building
Requirements:
- [RGBDS][rgbds] v0.5.0 or later
- [SuperFamiconv][superfamiconv] `f4b4254` or later
- [GNU Make][make]

[rgbds]: https://github.com/gbdev/rgbds
[superfamiconv]: https://github.com/Optiroc/SuperFamiconv
[make]: https://www.gnu.org/software/make

After cloning this repository, run `make` in the root directory of the
repository to produce the `bin` directory, containing `rhythm-land.gb`
along with its map and symbol files.

```bash
git clone https://github.com/sinusoid-studios/rhythm-land.git
cd rhythm-land
make
```

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
Driver][soundsystem]. It is licensed under the MIT License, a copy of
which can be found in [LICENSE.SoundSystem](/LICENSE.SoundSystem). Note,
however, that [SoundSystem.asm](/code/SoundSystem.asm) has been modified
from the original to work better with Rhythm Land, and
[SoundSystem.def](/constants/SoundSystem.def) contains driver
configuration specifically for Rhythm Land.

[soundsystem]: https://github.com/BlitterObjectBob/GBSoundSystem/tree/a8468d766b1f32fa31ab206f291bc71d3c5b133e

### gb-vwf
Files:
- [code/vwf.asm](/code/vwf.asm)
- [tools/make_font.py](/tools/make_font.py)

The files listed above are from Eldred Habert's [gb-vwf text
engine][gb-vwf]. It is licensed under the MIT License, a copy of which
can be found in [LICENSE.gb-vwf](/LICENSE.gb-vwf).

[gb-vwf]: https://github.com/ISSOtm/gb-vwf/tree/08c9305b1a2455b30e8441198fa42581f39ea880
