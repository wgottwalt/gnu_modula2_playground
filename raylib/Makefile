M2C = $(CROSS_COMPILE)gm2

BINARIES = 000_basic_window 001_title_screen 002_2d_camera 003_2d_camera_mouse_zoom \
           004_2d_camera_platformer 005_2d_camera_split_screen 006_3d_camera_first_person \
           007_initialize_3d_camera_free 008_initialize_3d_camera_mode 009_3d_camera_split_screen
SRC_DIR = source
OBJ_DIR = .obj

M2SOURCES = $(wildcard $(SRC_DIR)/*.mod)
SOURCES = $(filter-out $(addprefix $(SRC_DIR)/, $(addsuffix .mod, $(BINARIES))), $(M2SOURCES))
OBJECTS = $(patsubst $(SRC_DIR)/%.mod,$(OBJ_DIR)/%.o,$(SOURCES))

FLAGS = -W -Wall -Wextra -Oz -s
M2FLAGS = -fiso -fsoft-check-all -I$(SRC_DIR) $(FLAGS)
LIBS = -lraylib

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
