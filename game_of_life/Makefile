BINARIES = GameOfLife TestTime
SRC_DIR = source
OBJ_DIR = .obj

M2C = $(CROSS_COMPILE)gm2
FLAGS = -W -Wall -Wextra -O3 -Wl,--gc-sections -s
M2FLAGS = -ffunction-sections -fdata-sections -fiso -fsoft-check-all -I$(SRC_DIR) $(FLAGS)
LIBS =

M2SOURCES = $(wildcard $(SRC_DIR)/*.mod)
SOURCES = $(filter-out $(addprefix $(SRC_DIR)/, $(addsuffix .mod, $(BINARIES))), $(M2SOURCES))
OBJECTS = $(patsubst $(SRC_DIR)/%.mod,$(OBJ_DIR)/%.o,$(SOURCES))

all: $(OBJ_DIR) $(BINARIES)

$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.mod
	$(M2C) $(M2FLAGS) -c $< -o $@

$(BINARIES): %: $(SRC_DIR)/%.mod $(OBJECTS)
	$(M2C) $(M2FLAGS) $< $(OBJECTS) -o $@ $(LIBS)

clean:
	$(RM) -rf $(OBJ_DIR)

distclean: clean
	$(RM) $(BINARIES)

.PHONY: all clean
