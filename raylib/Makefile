M2C = $(CROSS_COMPILE)gm2
STRIP = $(CROSS_COMPILE)strip

BINARIES = 000_basic_window 001_title_screen 002_2d_camera 003_2d_camera_mouse_zoom
M2SOURCES = $(wildcard *.mod)
SOURCES = $(filter-out $(addsuffix .mod, $(BINARIES)), $(M2SOURCES))
OBJECTS = $(SOURCES:.mod=.o)

FLAGS = -W -Wall -Wextra -O3 -s
M2FLAGS = -static-libgm2 -fiso -fsoft-check-all $(FLAGS)
LIBS = -lraylib

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
