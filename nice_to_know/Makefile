M2C = $(CROSS_COMPILE)gm2

BINARIES = NestedVariadicRecords ProceduresAreConstants
M2SOURCES = $(wildcard *.mod)
SOURCES = $(filter-out $(addsuffix .mod, $(BINARIES)), $(M2SOURCES))
OBJECTS = $(SOURCES:.mod=.o)

FLAGS = -W -Wextra -O2 -s
M2FLAGS = -fiso -fsoft-check-all $(FLAGS)
LIBS =

all: $(BINARIES)

%.o: %.mod
	$(M2C) $(M2FLAGS) -c $< -o $@

$(BINARIES): %: %.mod $(OBJECTS)
	$(M2C) $(M2FLAGS) $< $(OBJECTS) -o $@ $(LIBS)

clean:
	$(RM) $(OBJECTS)

distclean: clean
	$(RM) $(BINARIES)

.PHONY: all clean
