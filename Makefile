.SUFFIXES:

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

INCDIRS = code include
WARNINGS := all extra

ASFLAGS  = -h $(addprefix -i ,$(INCDIRS)) -p $(PADVALUE) $(addprefix -W,$(WARNINGS))
LDFLAGS  = -p $(PADVALUE)
FIXFLAGS = -v -p $(PADVALUE) -i "$(MFRCODE)" -k "$(LICENSEE)" -l $(OLDLIC) -m $(MBC) -n $(VERSION) -r $(SRAMSIZE) -t "$(TITLE)" -j

PALFLAGS = -R
TILEFLAGS = -B 2 -R -T 256
res/%.obj.2bpp: TILEFLAGS += -H 16
res/%.bg.2bpp: TILEFLAGS += -F
MAPFLAGS = -B 2 -F

SRCS := $(wildcard code/*.asm) $(wildcard code/**/*.asm) $(wildcard data/*.asm) $(wildcard data/**/*.asm)
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
bin/%.gb bin/%.sym bin/%.map: $(GFX) $(patsubst %.asm,obj/%.o,$(SRCS))
	@mkdir -p $(@D)
	rgblink $(LDFLAGS) -m bin/$*.map -n bin/$*.sym -o bin/$*.gb $(patsubst %.asm,obj/%.o,$(SRCS))
	rgbfix $(FIXFLAGS) bin/$*.gb

# Assemble an assembly file and save dependencies
obj/%.o dep/%.mk: $(GFX) %.asm
	@mkdir -p obj/$(*D) dep/$(*D)
	rgbasm $(ASFLAGS) -i $(*D) -M dep/$*.mk -MG -MP -MQ obj/$*.o -MQ dep/$*.mk -o obj/$*.o $*.asm

# Graphics conversion
res/%.pal.json: gfx/%.png
	@mkdir -p $(@D)
	superfamiconv palette -M gb $(PALFLAGS) -i $< -j $@
res/%.2bpp: gfx/%.png res/%.pal.json
	@mkdir -p $(@D)
	superfamiconv tiles -M gb $(TILEFLAGS) -i $< -p res/$*.pal.json -d $@
res/%.1bpp: gfx/%.png res/%.pal.json
	@mkdir -p $(@D)
	superfamiconv tiles -M gb $(TILEFLAGS) -B 1 -i $< -p res/$*.pal.json -d $@
res/%.tilemap: gfx/%.png res/%.2bpp res/%.pal.json
	@mkdir -p $(@D)
	superfamiconv map -M gb $(MAPFLAGS) -i $< -t res/$*.2bpp -p res/$*.pal.json -d $@

# Don't include dependencies if cleaning
ifneq ($(MAKECMDGOALS),clean)
-include $(patsubst %.asm,dep/%.mk,$(SRCS) $(ST_SRCS))
endif
