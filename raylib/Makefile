M2C = $(CROSS_COMPILE)gm2

BINARIES = 000_basic_window 001_title_screen 002_2d_camera 003_2d_camera_mouse_zoom \
           004_2d_camera_platformer 005_2d_camera_split_screen 006_3d_camera_first_person \
           007_initialize_3d_camera_free
M2SOURCES = $(wildcard *.mod)
SOURCES = $(filter-out $(addsuffix .mod, $(BINARIES)), $(M2SOURCES))
OBJECTS = $(patsubst %.mod,.obj/%.o,$(SOURCES))
OBJDIR = .obj

FLAGS = -W -Wall -Wextra -O2 -s
M2FLAGS = -fiso -fsoft-check-all $(FLAGS)
LIBS = -lraylib

all: $(OBJDIR) $(BINARIES)

$(OBJDIR):
	mkdir -p $(OBJDIR)

$(OBJDIR)/%.o: %.mod
	$(M2C) $(M2FLAGS) -c $< -o $@

$(BINARIES): %: %.mod $(OBJECTS)
	$(M2C) $(M2FLAGS) $< $(OBJECTS) -o $@ $(LIBS)

clean:
	$(RM) -rf $(OBJDIR)

distclean: clean
	$(RM) $(BINARIES)

.PHONY: all clean
