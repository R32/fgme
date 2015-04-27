#---------------------------------------------------------------------------------
.SUFFIXES:
#---------------------------------------------------------------------------------
TOPDIR	:=	$(CURDIR)

OUTBIN	:=	libgme.swc

#---------------------------------------------------------------------------------
# the prefix on the compiler executables
#---------------------------------------------------------------------------------
PREFIX	:=
CC		:=	$(PREFIX)gcc
CXX		:=	$(PREFIX)g++

#---------------------------------------------------------------------------------
# BUILD is the directory where object files & intermediate files will be placed
# SOURCES is a list of directories containing source code
# INCLUDES is a list of directories containing extra header files
# DATA is a list of directories containing binary files
# LIB is where the built library will be placed
# all directories are relative to this makefile
#---------------------------------------------------------------------------------
BUILD		:=	release
SOURCES		:=	../../project/gme-master/gme
INCLUDES	:=	-I/cygdrive/d/alchemy/avm2-libc/include -I$(SOURCES)
DATA		:=
LIB			:=

#---------------------------------------------------------------------------------
$(BUILD)/%.o: %.cpp
	@echo $(notdir $<)
	$(CXX) $(CXXFLAGS) -c $< -o $@
	
#---------------------------------------------------------------------------------
$(BUILD)/%.o: %.c
	@echo $(notdir $<)
	$(CC) $(CFLAGS) -c $< -o $@

#---------------------------------------------------------------------------------
# options for code generation
#---------------------------------------------------------------------------------
CFLAGS		:=	-Wall -O3\
				-ffast-math -fno-rtti -fno-exceptions

CFLAGS		+=	$(INCLUDES)

CXXFLAGS	:=	$(CFLAGS)

#---------------------------------------------------------------------------------
# any extra libraries we wish to link with the project
#---------------------------------------------------------------------------------

LIBS	:=-L/cygdrive/d/alchemy/avm2-libc/lib

#---------------------------------------------------------------------------------

VPATH		:=	$(CURDIR) $(SOURCES)

CFILES		:=	$(foreach dir,$(SOURCES),$(notdir $(wildcard $(dir)/*.c)))

CPPFILES	:=	$(foreach dir,$(SOURCES),$(notdir $(wildcard $(dir)/*.cpp)))
CPPFILES	+=	glue.cpp

OFILES		:=	$(addprefix $(BUILD)/, $(CPPFILES:.cpp=.o) $(CFILES:.c=.o))


.PHONY: $(BUILD) clean
#---------------------------------------------------------------------------------
all: $(BUILD) $(OUTBIN)

clean:
	@echo clean ...
	@rm -fr debug release $(OUTBIN)
	
$(BUILD):
	@[ -d $@ ] || mkdir -p $@
	
#---------------------------------------------------------------------------------
# main targets
#---------------------------------------------------------------------------------
$(OUTBIN): $(OFILES) Makefile
	@rm -f "$(OUTBIN)"
	$(CC) $(OFILES) -swc -o "$(OUTBIN)"
	@echo file: $@