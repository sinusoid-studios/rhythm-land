# Soundtest
The [soundtest.asm][soundtest] and [font.bin][font] files in this
directory are taken from [SoundSystem's "Example"][example]
(soundtest.asm originally named Example.asm). It is thus licensed under
the MIT License, a copy of which can be found in
[LICENSE.SoundSystem](/LICENSE.SoundSystem). Note, however, that
soundtest.asm has been modified from the original to work better with
Rhythm Land.

[soundtest]: /soundtest/soundtest.asm
[font]: /soundtest/font.bin
[example]: https://github.com/BlitterObjectBob/GBSoundSystem/tree/a8468d766b1f32fa31ab206f291bc71d3c5b133e/Example

## Building
Requirements:
- [RGBDS][rgbds] v0.5.1 or later
- [GNU Make][make]

[rgbds]: https://github.com/gbdev/rgbds
[make]: https://www.gnu.org/software/make

Run `make` in the `soundtest` directory of the repository to produce the
`bin` subdirectory, containing `soundtest.gb` along with its map and
symbol files.
