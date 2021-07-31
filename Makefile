.SUFFIXES:

ifeq ($(OS),Windows_NT)
PYTHON := py -3
else
PYTHON := python3
endif

# Project configuration
PADVALUE := 0xFF

VERSION := 0
MFRCODE := SNSD
TITLE := RHYTHM LAND
bin/soundtest.gb: TITLE := SOUNDTEST
LICENSEE := HB
OLDLIC := 0x33
MBC := MBC5
SRAMSIZE := 0

WARNINGS := all extra

ASFLAGS  = -h -p $(PADVALUE) $(addprefix -W,$(WARNINGS))
LDFLAGS  = -p $(PADVALUE) -d
FIXFLAGS = -v -p $(PADVALUE) -i "$(MFRCODE)" -k "$(LICENSEE)" -l $(OLDLIC) -m $(MBC) -n $(VERSION) -r $(SRAMSIZE) -t "$(TITLE)" -j

PALFLAGS := -R
TILEFLAGS := -B 2 -R -T 256
GFXFLAGS := -u
res/skater-dude/background.bg.2bpp: GFXFLAGS += -h

SRCS := $(wildcard code/*.asm) $(wildcard code/*/*.asm) $(wildcard data/*.asm) $(wildcard data/*/*.asm) $(wildcard data/*/*/*.asm)
ST_SRCS := code/SoundSystem.asm $(wildcard data/music/*.asm) data/sfx.asm soundtest/soundtest.asm

game: bin/rhythm-land.gb
.PHONY: game

soundtest: bin/soundtest.gb
.PHONY: soundtest

clean:
	rm -rf bin
	rm -rf obj
	rm -rf dep
	rm -rf res
.PHONY: clean

rebuild:
	$(MAKE) clean
	$(MAKE) game
.PHONY: rebuild

# Build the soundtest ROM
bin/soundtest.gb: $(patsubst %.asm,obj/%.o,$(ST_SRCS))
	@mkdir -p $(@D)
	rgblink $(LDFLAGS) -o $@ $^
	rgbfix $(FIXFLAGS) $@

# Build the game, along with map and symbol files
bin/%.gb bin/%.sym bin/%.map: $(patsubst %.asm,obj/%.o,$(SRCS))
	@mkdir -p $(@D)
	rgblink $(LDFLAGS) -m bin/$*.map -n bin/$*.sym -o bin/$*.gb $^
	rgbfix $(FIXFLAGS) bin/$*.gb

# Assemble an assembly file and save dependencies
obj/%.o dep/%.mk: %.asm
	@mkdir -p obj/$(*D) dep/$(*D)
	rgbasm $(ASFLAGS) -i $(*D) -M dep/$*.mk -MG -MP -MQ obj/$*.o -MQ dep/$*.mk -o obj/$*.o $<

# Graphics conversion
res/%.pal.json: gfx/%.png
	@mkdir -p $(@D)
	superfamiconv palette -M gb $(PALFLAGS) -i $< -j $@
res/%.obj.2bpp: gfx/%.obj.png res/%.obj.pal.json
	@mkdir -p $(@D)
	superfamiconv tiles -M gb $(TILEFLAGS) -H 16 -i $< -p res/$*.obj.pal.json -d $@
res/%.bg.2bpp res/%.bg.tilemap: gfx/%.bg.png
	@mkdir -p $(@D)
	rgbgfx $(GFXFLAGS) -o res/$*.bg.2bpp -t res/$*.bg.tilemap $<

# Font data generation
res/%.vwf: gfx/%.png
	@mkdir -p $(@D)
	$(PYTHON) tools/make_font.py $< $@

# Don't include dependencies if cleaning
ifneq ($(MAKECMDGOALS),clean)
ifneq ($(MAKECMDGOALS),soundtest)
-include $(patsubst %.asm,dep/%.mk,$(SRCS))
else
-include $(patsubst %.asm,dep/%.mk,$(ST_SRCS))
endif
endif
