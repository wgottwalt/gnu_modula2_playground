M2C = $(CROSS_COMPILE)gm2
STRIP = $(CROSS_COMPILE)strip

BINARIES = ImageViewer
M2SOURCES = $(wildcard *.mod)
SOURCES = $(filter-out $(addsuffix .mod, $(BINARIES)), $(M2SOURCES))
OBJECTS = $(SOURCES:.mod=.o)

FLAGS = -W -Wextra -Os -s
M2FLAGS = -static-libgm2 -fiso -fsoft-check-all $(FLAGS)
LIBS = -lSDL2 -lSDL2_image

all: $(BINARIES)

%.o: %.mod
	$(M2C) $(M2FLAGS) -c $< -o $@

$(BINARIES): %: %.mod $(OBJECTS)
	$(M2C) $(M2FLAGS) $< $(OBJECTS) -o $@ $(LIBS)
	@$(STRIP) $@

clean:
	$(RM) $(OBJECTS) $(BINARIES:=.o)

distclean: clean
	$(RM) $(BINARIES)

.PHONY: all clean
