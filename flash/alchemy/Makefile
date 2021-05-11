#
SWC := libgme.swc
LIB := libgme.a

BUILD    := bin
SOURCES  := ../../project/gme-master/gme
INCLUDES := -I$(SOURCES)

# BUG: -DNDEBUG seems doesn't work
CFLAGS   := -Wall -DNODEBUG -O3 -ffast-math -fno-rtti -fno-exceptions
CFLAGS   += $(INCLUDES)
CXXFLAGS := $(CFLAGS)

CC       := gcc
CXX      := g++

VPATH    := $(CURDIR) $(SOURCES)
CFILES   := $(notdir $(wildcard $(SOURCES)/*.c))
CPPFILES :=	$(notdir $(wildcard $(SOURCES)/*.cpp))
BINFILES := $(addprefix $(BUILD)/, $(CPPFILES:.cpp=.o) $(CFILES:.c=.o))


all: $(BUILD) $(SWC)

clean:
	@echo clean ...
	@rm -fr $(BUILD)/** $(SWC)

.PHONY: all clean

$(BUILD)/%.o: %.cpp
	@$(CXX) $(CXXFLAGS) -c $< -o $@
	@echo Compile $< TO $@

$(BUILD)/%.o: %.c
	@echo $(notdir $<)
	$(CC) $(CFLAGS) -c $< -o $@

# libgme.a
$(BUILD)/$(LIB): $(BINFILES)
	@ar rcs $@ $^
	@echo Archived $@

# make output dir
$(BUILD):
	@mkdir -p $@

$(SWC): $(BUILD)/glue.o $(BUILD)/$(LIB)
	@rm -f "$@"
	$(CC) $< -lgme -L$(BUILD) -swc -o $@
	@echo file: $@
