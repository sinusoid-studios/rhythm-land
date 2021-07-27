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
