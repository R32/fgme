#
SWC := libgme.swc
LIB := libgme.a

BUILD    := release
SOURCES  := ../../project/gme-master/gme
INCLUDES := -I$(SOURCES)

CFLAGS   := -Wall -O3 -ffast-math -fno-rtti -fno-exceptions
CFLAGS   += $(INCLUDES)
CXXFLAGS := $(CFLAGS)

CC       := $(PREFIX)gcc
CXX      := $(PREFIX)g++
VPATH    := $(CURDIR) $(SOURCES)
CFILES   := $(notdir $(wildcard $(SOURCES)/*.c))
CPPFILES :=	$(notdir $(wildcard $(SOURCES)/*.cpp))
BINFILES := $(addprefix $(BUILD)/, $(CPPFILES:.cpp=.o) $(CFILES:.c=.o))

all: $(BUILD) $(SWC)

clean:
	@echo clean ...
	@rm -fr debug release $(SWC)

.PHONY: $(BUILD) clean

$(BUILD)/%.o: %.cpp
	@echo $(notdir $<)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(BUILD)/%.o: %.c
	@echo $(notdir $<)
	$(CC) $(CFLAGS) -c $< -o $@

# libgme.a
$(BUILD)/$(LIB): $(BINFILES)
	ar rcs $@ $^

# make output dir
$(BUILD):
	@[ -d $@ ] || mkdir -p $@

$(SWC): $(BUILD)/glue.o $(BUILD)/$(LIB)
	@rm -f "$@"
	$(CC) $< -lgme -L$(BUILD) -swc -o $@
	@echo file: $@
