.SUFFIXES:

# Project configuration
PADVALUE := 0xFF
VERSION := 0
MFRCODE := SNSD
TITLE := SOUNDTEST
LICENSEE := HB
OLDLIC := 0x33
MBC := MBC5
SRAMSIZE := 0

WARNINGS := all extra

ASFLAGS  = -h -p $(PADVALUE) $(addprefix -W,$(WARNINGS))
LDFLAGS  = -p $(PADVALUE) -d
FIXFLAGS = -v -p $(PADVALUE) -i "$(MFRCODE)" -k "$(LICENSEE)" -l $(OLDLIC) -m $(MBC) -n $(VERSION) -r $(SRAMSIZE) -t "$(TITLE)" -j

# SoundSystem, music data, and sound effect data are not in this
# directory, but in subdirectories of the parent directory
VPATH := ..

SRCS := code/SoundSystem.asm $(subst ../,,$(wildcard ../data/music/*.asm)) data/sfx.asm soundtest.asm

all: bin/soundtest.gb
.PHONY: all

clean:
	rm -rf bin
	rm -rf obj
	rm -rf dep
.PHONY: clean

rebuild:
	$(MAKE) clean
	$(MAKE)
.PHONY: rebuild

# Build a ROM, along with map and symbol files
bin/%.gb bin/%.sym bin/%.map: $(patsubst %.asm,obj/%.o,$(SRCS))
	@echo $(wildcard ../data/music/*.asm)
	@echo $(wildcard data/music/*.asm)
	@echo $(subst ../,,$(wildcard ../data/music/*.asm))
	@mkdir -p $(@D)
	rgblink $(LDFLAGS) -m bin/$*.map -n bin/$*.sym -o bin/$*.gb $^
	rgbfix $(FIXFLAGS) bin/$*.gb

# Assemble an assembly file and save dependencies
obj/%.o dep/%.mk: %.asm
	@mkdir -p obj/$(*D) dep/$(*D)
	rgbasm $(ASFLAGS) -i .. -M dep/$*.mk -MG -MP -MQ obj/$*.o -MQ dep/$*.mk -o obj/$*.o $<

# Don't include dependencies if cleaning
ifneq ($(MAKECMDGOALS),clean)
-include $(patsubst %.asm,dep/%.mk,$(SRCS))
endif
