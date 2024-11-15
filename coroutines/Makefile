M2C = $(CROSS_COMPILE)gm2

BINARIES = Coroutines
M2SOURCES = $(wildcard *.mod)
SOURCES = $(filter-out $(addsuffix .mod, $(BINARIES)), $(M2SOURCES))
OBJECTS = $(patsubst %.mod,.obj/%.o,$(SOURCES))
OBJDIR = .obj

FLAGS = -W -Wextra -Wall -O2 -s
M2FLAGS = -fsoft-check-all $(FLAGS)
LIBS =

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
