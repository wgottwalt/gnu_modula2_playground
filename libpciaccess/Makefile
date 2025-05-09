CC = $(CROSS_COMPILE)cc
M2C = $(CROSS_COMPILE)gm2
STRIP = $(CROSS_COMPILE)strip

CBINARIES = CTestPackedTypes
CSOURCES = $(filter-out $(addsuffix .c, $(CBINARIES)), $(wildcard *.c))
COBJECTS = $(patsubst %.c,.obj/%.o,$(CSOURCES))

M2BINARIES = M2TestPackedTypes ListDevices
M2SOURCES = $(filter-out $(addsuffix .mod, $(M2BINARIES)), $(wildcard *.mod))
M2OBJECTS = $(patsubst %.mod,.obj/%.o,$(M2SOURCES))

OBJDIR = .obj

FLAGS = -W -Wextra -O2 -s
CFLAGS = -std=c18 -Wall -flto $(FLAGS)
M2FLAGS = -fiso -fsoft-check-all $(FLAGS)
LIBS = -lpciaccess

all: $(OBJDIR) $(CBINARIES) $(M2BINARIES)

$(OBJDIR):
	mkdir -p $(OBJDIR)

$(OBJDIR)/%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJDIR)/%.o: %.mod
	$(M2C) $(M2FLAGS) -c $< -o $@

$(CBINARIES): %: %.c $(COBJECTS)
	$(CC) $(CFLAGS) $< $(COBJECTS) -o $@ $(LIBS)
	@$(STRIP) $@ 

$(M2BINARIES): %: %.mod $(M2OBJECTS)
	$(M2C) $(M2FLAGS) $< $(M2OBJECTS) -o $@ $(LIBS)
	@$(STRIP) $@

clean:
	$(RM) -rf $(OBJDIR)

distclean: clean
	$(RM) $(CBINARIES) $(M2BINARIES)

.PHONY: all clean
