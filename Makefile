.SUFFIXES:

# Project configuration
PADVALUE := 0xFF

VERSION := 0
MFRCODE := SNSD
TITLE := RHYTHM LAND
LICENSEE := HB
OLDLIC := 0x33
MBC := ROM
SRAMSIZE := 0

INCDIRS = code include
WARNINGS := all extra

ASFLAGS  = -h $(addprefix -i ,$(INCDIRS)) -p $(PADVALUE) $(addprefix -W,$(WARNINGS))
LDFLAGS  = -p $(PADVALUE)
FIXFLAGS = -v -p $(PADVALUE) -i "$(MFRCODE)" -k "$(LICENSEE)" -l $(OLDLIC) -m $(MBC) -n $(VERSION) -r $(SRAMSIZE) -t "$(TITLE)" -j -c

SRCS := $(wildcard code/*.asm) $(wildcard data/*.asm) $(wildcard data/**/*.asm)

game: bin/rhythm-land.gbc
.PHONY: game

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

# Build the game, along with map and symbol files
bin/%.gbc bin/%.sym bin/%.map: $(GFX) $(patsubst %.asm,obj/%.o,$(SRCS))
	@mkdir -p $(@D)
	rgblink $(LDFLAGS) -m bin/$*.map -n bin/$*.sym -o bin/$*.gbc $(patsubst %.asm,obj/%.o,$(SRCS))
	rgbfix $(FIXFLAGS) bin/$*.gbc

# Assemble an assembly file and save dependencies
obj/%.o dep/%.mk: $(GFX) %.asm
	@mkdir -p obj/$(*D) dep/$(*D)
	rgbasm $(ASFLAGS) -i $(*D) -M dep/$*.mk -MG -MP -MQ obj/$*.o -MQ dep/$*.mk -o obj/$*.o $*.asm

# Graphics conversion
res/%.pal.json: gfx/%.png
	@mkdir -p $(@D)
	superfamiconv palette -M gb -R -i $< -j $@
res/%.2bpp: gfx/%.png res/%.pal.json
	@mkdir -p $(@D)
	superfamiconv tiles -M gb -B 2 -R -F -T 256 -i $< -p res/$*.pal.json -d $@
res/%.1bpp: gfx/%.png res/%.pal.json
	@mkdir -p $(@D)
	superfamiconv tiles -M gb -B 1 -R -F -T 256 -i $< -p res/$*.pal.json -d $@
res/%.tilemap: gfx/%.png res/%.2bpp res/%.pal.json
	@mkdir -p $(@D)
	superfamiconv map -M gb -B 2 -F -i $< -t res/$*.2bpp -p res/$*.pal.json -d $@

# Don't include dependencies if cleaning
ifneq ($(MAKECMDGOALS),clean)
-include $(patsubst %.asm,dep/%.mk,$(SRCS))
endif
