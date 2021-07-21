# Actor Data
This directory contains [animation](#animation-tables),
[meta-sprite](#meta-sprite-tables), and [tile](#tile-tables) tables for
actors.

## Animation Tables
The naming convention for animation tables is `xActor<name>Animation`,
where `<name>` is the name of the actor in PascalCase. For example,
[Skater Dude's animation table][skater-dude-animation] is called
`xActorSkaterDudeAnimation`.

```assembly
xActor<name>Animation::
    animation <name>[, <const_name>]

    cel ...
    cel ...
    ...
```

### `animation`
This macro doesn't actually emit any data, it's just to allow the other
macros to work without specifying full label names, i.e.
`cel metasprite` rather than `cel xActor<name>Metasprites.metasprite`.

An animation name for cel constants can also be specified through
`<const_name>` and will be used with the [`cel_def` macro](#cel_def) for
giving certain cels names. If the `cel_def` macro is never used, it's
unnecessary to specify `<const_name>` since it's the only thing that
uses it.

### Cels
An animation table consists mostly of *cels*, each of which are 2 bytes
large, containing a meta-sprite number followed by a duration in frames.
After the cel duration is over, the following cel is used.

Note that when an actor is first created, its current animation cel is
automatically set to 0.

The `cel` macro automatically calculates meta-sprite numbers and allows
for simply using the meta-sprite name (from the [meta-sprite
table](#meta-sprite-tables)).

#### Usage
```assembly
    cel <metasprite>, <duration>
```

`<metasprite>` will be the local part of a
[meta-sprite](#meta-sprites)'s label.

`<duration>` is an 8-bit number representing the number of frames the
cel lasts. A value of -1 or `ANIMATION_DURATION_FOREVER` makes the cel
last forever.

#### Example
```assembly
xActorSampleAnimation::
    animation Sample

    cel sample1, 10
    cel sample2, 10
    cel sample3, MUSIC_THEME_SPEED
```
This animation will use the `sample1` meta-sprite for 10 frames,
followed by the `sample2` meta-sprite for 10 frames, followed by the
`sample3` meta-sprite for `MUSIC_THEME_SPEED` frames.

### Commands
There are several *commands* that can be used in an animation:
- ["Goto"](#goto-command) &mdash; Jump to a specific cel, useful for
looping.
- ["Kill Actor"](#kill-actor-command) &mdash; Remove the actor when its
animation reaches this command.\
**WARNING**: This must be used *outside* of an override animation!
- ["Override End"](#override-end-command) &mdash; End an animation
override.\
**WARNING**: This must be used *inside* of an override animation!
- ["Set Tiles"](#set-tiles-command) &mdash; Copy tiles to the actor's
reserved tile space in VRAM.

### "Goto" Command
The `goto_cel` macro allows for automatic cel number calculation.

#### Usage
```assembly
    goto_cel <cel>
```

`<cel>` should be a local label defined in the animation table.

#### Example
```assembly
xActorSampleAnimation::
    animation Sample

.loop
    cel sample1, 10
    cel sample2, 10
    goto_cel .loop
```
This animation will use the `sample1` meta-sprite for 10 frames,
followed by the `sample2` meta-sprite for 10 frames. Then, it will jump
back to the `sample1` meta-sprite and the animation will loop forever.

### "Kill Actor" Command
This command doesn't have a macro because only the "Kill Actor" command
byte is necessary. Note that the animation will not run past a "Kill
Actor" command &mdash; the actor is killed immediately when it's
reached.

#### Usage
```assembly
    DB ANIMATION_KILL_ACTOR
```

#### Example
```assembly
xActorSampleAnimation::
    animation Sample

    cel sample, 60
    DB ANIMATION_KILL_ACTOR
```
This animation will use the `sample` meta-sprite for 60 frames. The
actor will then be killed.

### "Override End" Command
The `override_end` macro should be used for creating an "Override End"
command for specifying tiles that need to be reloaded before returning
to the main animation. If tiles don't need to be reloaded (i.e. the
game's actors don't stream tiles or the override animation uses the same
tiles), don't specify a label.

#### Usage
```assembly
    override_end [<set_tiles>]
```

`<set_tiles>`, if specified, must point to a ["Set Tiles"
command](#set-tiles-command), or else the game will probably break.

#### Example
```assembly
xActorSampleAnimation::
    animation Sample

    ; Main animation
.walkLoop
    cel walk1, 10
    cel walk2, 10
    goto_cel .walkLoop

    ; Override animation
    cel jump, 20
    override_end
```
This override animation will use the `jump` meta-sprite for 20 frames
and then return to the main animation without changing any tiles.

#### Example
```assembly
xActorSampleAnimation::
    animation Sample

    ; Main animation
.walk
    set_tiles walk, 8
.walkLoop
    cel walk1, 10
    cel walk2, 10
    goto_cel .walkLoop

    ; Override animation
    set_tiles jump, 8       ; Tiles are overwritten
    cel jump, 20
    override_end .walk      ; Go back to .walk to reload walk tiles
```
Since the jump override animation overwrites the actor's tiles (from
`walk` to `jump`), it's necessary to reload the `walk` tiles before
continuing the walk animation. The label `.walk`, which points to the
"Set Tiles" command for the `walk` tiles, is given to the `override_end`
macro.

### "Set Tiles" Command
The `set_tiles` macro allows for using just the local part of tile data
labels rather than the entire thing, as well as specifying number of
tiles rather than half the number of bytes.

#### Usage
```assembly
    set_tiles <tiles>, <count>
```

`<tiles>` is the local part of a label pointing to the [tile
data](#tile-tables) to copy to the actor's reserved tile space in VRAM.

**WARNING**: The tile data that `<tiles>` points to must be in the same
ROM bank as the animation table. Ensuring this is true can be done by
simply placing the [tile table](#tile-tables) in the same section.

`<count>` is the number of tiles to copy.

**WARNING**: There are only 8 reserved tiles for each actor. If an actor
that uses tile streaming has a meta-sprite that needs more, the
`NUM_ACTOR_RESERVED_TILES` constant in
[constants/actors.inc](/constants/actors.inc) needs to be changed and
the reserved tile pointer calculation in `ActorsSetTiles` in
[code/actors.asm](/code/actors.asm) updated to reflect the new value.

#### Example
```assembly
xActorSampleAnimation::
    animation Sample

    set_tiles sample, 5

xActorSampleTiles:
.sample
    INCBIN "res/sample-game/sample/sample.obj.2bpp"
```
This will load 5 tiles from `xActorSampleTiles.sample`, which points to
the converted graphics data originally from the image at
`gfx/sample-game/sample/sample.obj.png`.

### `cel_def`
This macro just creates and exports a constant with a value of the cel
number of a specific cel. Useful for setting an actor's cel in code,
such as in its actor update routine.

The constants follow the format `CEL_<const_name>_<cel_name>`.

#### Usage
```assembly
    cel_def <cel>, <cel_name>
```

`<cel>` should be a local label pointing to the target cel in the
animation table.

`<cel_name>` is used as the last part of the constant's name.

#### Example
```assembly
xActorBearAnimation::
    animation Bear, BEAR

.sleep
    cel sleep, ANIMATION_DURATION_FOREVER
    
    cel_def .sleep, SLEEP
```
This would create and export a constant named `CEL_BEAR_SLEEP` with a
value of 0, since the cel that `.sleep` references is the first cel
(0-based).

## Meta-Sprite Tables
The naming convention for meta-sprite tables is
`xActor<name>Metasprites`, where `<name>` is the name of the actor in
PascalCase. For example, [Skater Dude's meta-sprite
table][skater-dude-metasprites] is called `xActorSkaterDudeMetasprites`.

```assembly
xActor<name>Metasprites::
    metasprite ...
    metasprite ...
    ...
```

### Meta-Sprites
Meta-sprites are groups of objects used to create a large sprite. A
meta-sprite definition contains this group of objects, with the only
twist being that the object's position is relative to the actor's
position.

#### Usage
```assembly
xActor<name>Metasprites::
    metasprite .sample
    ...

.sample
    DB <y>, <x>, <tile>, <attrs>
    ...
    DB METASPRITE_END
```

Each object in a meta-sprite is 4 bytes large, containing data in the
same order as in OAM.

The `METASPRITE_END` special value tells the actor renderer that there
are no more objects.

#### Example
```assembly
xActorSampleMetasprites::
    metasprite .sample

.sample
    DB 0, 8, $00, OAMF_PAL1
    DB METASPRITE_END
```
This meta-sprite consists of a single object using tile $00. It is
placed at (8, 0) relative to the actor's position. It also uses OBP1
(the second object palette).

### `metasprite`
The `metasprite` macro assigns the meta-sprite number to a constant for
use in the `cel` macro, and emits a pointer to the actual [meta-sprite
definition](#meta-sprites).

#### Usage
```assembly
xActor<name>Metasprites::
    metasprite <metasprite>

<metasprite>
    ; Meta-sprite definition
```

`<metasprite>` should be a local label pointing to the metasprite
definition elsewhere in the table.

#### Example
```assembly
xActorSampleMetasprites::
    metasprite .sample1
    metasprite .sample2

.sample1
    ; Meta-sprite definition
.sample2
    ; Meta-sprite definition
```
And in the animation table, the `cel` macro can use the names `sample1`
and `sample2`:
```assembly
xActorSampleAnimation::
    animation Sample

    cel sample1, 10
    cel sample2, 10
```
When `sample1` is used in the [`cel` macro](#cels), it's referring to
the meta-sprite defined at `xActorSampleMetasprites.sample1`.

## Tile Tables
Tile tables are only used in actors who need to stream their tiles.
Otherwise, the game's setup routine should preload all tiles for actors
to use.

The naming convention for tile tables is `xActor<name>Tiles`, where
`<name>` is the name of the actor in PascalCase. For example, [Seagull
1's tile table][seagull-1-tiles] is called `xActorSeagull1Tiles`.

**WARNING**: Tile tables must be placed in the same ROM bank as their
corresponding animation tables. Ensuring this is true can be done by
simply placing the [animation table](#animation-tables) in the same
section.

```assembly
xActor<name>Tiles::
.sample1
    INCBIN "res/sample-game/sample-actor/sample-1.obj.2bpp"
.sample2
    INCBIN "res/sample-game/sample-actor/sample-2.obj.2bpp"
...
```

### Labels
The local labels used in the tile table (`sample1` and `sample2` in the
snippet above) can be referenced in the [`set_tiles`
macro](#set-tiles-command).

[skater-dude-animation]: https://github.com/sinusoid-studios/rhythm-land/blob/08414669c10f9b38c66d27a0f8df6f34e9529eb7/data/actors/skater-dude.asm#L8
[skater-dude-metasprites]: https://github.com/sinusoid-studios/rhythm-land/blob/08414669c10f9b38c66d27a0f8df6f34e9529eb7/data/actors/skater-dude.asm#L50
[seagull-1-tiles]: https://github.com/sinusoid-studios/rhythm-land/blob/08414669c10f9b38c66d27a0f8df6f34e9529eb7/data/actors/seagull-1.asm#L28
