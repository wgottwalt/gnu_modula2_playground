CC = $(CROSS_COMPILE)cc
M2C = $(CROSS_COMPILE)gm2

BINARIES = 000_basic_window \
           001_title_screen \
           002_2d_camera \
           003_2d_camera_mouse_zoom \
           004_2d_camera_platformer \
           005_2d_camera_split_screen \
           006_3d_camera_first_person \
           007_initialize_3d_camera_free \
           008_initialize_3d_camera_mode \
           009_3d_camera_split_screen \
           010_picking_in_3d_mode \
           011_automation_events \
           012_custom_frame_control

SRC_DIR = source
OBJ_DIR = .obj

CSOURCES = $(wildcard $(SRC_DIR)/*.c)
M2SOURCES = $(wildcard $(SRC_DIR)/*.mod)
SOURCES = $(filter-out $(addprefix $(SRC_DIR)/, $(addsuffix .mod, $(BINARIES))), $(M2SOURCES))

COBJECTS = $(patsubst $(SRC_DIR)/%.c, $(OBJ_DIR)/%.o, $(CSOURCES))
MOBJECTS = $(patsubst $(SRC_DIR)/%.mod, $(OBJ_DIR)/%.o, $(SOURCES))

FLAGS = -W -Wall -Wextra -Oz -s
CFLAGS = -std=c18 -flto -I$(SRC_DIR) $(FLAGS)
M2FLAGS = -fiso -fsoft-check-all -I$(SRC_DIR) $(FLAGS)
ARFLAGS = rcs
LIBS = -lraylib

all: $(OBJ_DIR) $(BINARIES)

$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.mod
	$(M2C) $(M2FLAGS) -c $< -o $@

$(BINARIES): %: $(SRC_DIR)/%.mod $(COBJECTS) $(OBJECTS)
	$(M2C) $(M2FLAGS) $< $(COBJECTS) $(OBJECTS) -o $@ $(LIBS)

clean:
	$(RM) -rf $(OBJ_DIR)

distclean: clean
	$(RM) $(BINARIES)

.PHONY: all clean
