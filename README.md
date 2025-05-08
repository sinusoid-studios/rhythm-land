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
subdirectory, containing `rhythm-land.gb` along with its map and symbol
files.

## Credits
- [martendo][martendo] &mdash; Programming, Music &amp; SFX
- [Adrian-kwok][Adrian-kwok] &mdash; Art, Design
- [St&eacute;phane Hockenhull][rv6502] &mdash; [Game Boy Tracker][gb-tracker]
- [Bob Koon (BlitterObject)][blitterobject] &mdash; [SoundSystem sound driver][soundsystem]
- [Eldred Habert (ISSOtm)][issotm] &mdash; [gb-vwf text engine][gb-vwf]

See [ATTRIBUTION.md](/ATTRIBUTION.md) for more information.

[martendo]: https://github.com/martendo
[Adrian-kwok]: https://github.com/Adrian-kwok
[rv6502]: https://rv6502.ca
[blitterobject]: https://github.com/BlitterObjectBob
[issotm]: https://eldred.fr
[gb-tracker]: https://rv6502.ca/wiki/index.php?title=Game_Boy_Tracker
<!-- [soundsystem]: https://github.com/BlitterObjectBob/GBSoundSystem -->
[soundsystem]: https://github.com/gb-archive/GBSoundSystem
[gb-vwf]: https://github.com/ISSOtm/gb-vwf
