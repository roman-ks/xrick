
VCXPROJ := xrick/xrick.vcxproj
CONFIG ?= Release
PLATFORM ?= Win32

MSBUILD := $(shell command -v msbuild 2>/dev/null)
DOTNET := $(shell command -v dotnet 2>/dev/null)
GCC := $(shell command -v gcc 2>/dev/null)

CC ?= gcc
CFLAGS ?= -std=c11 -O2 -Wall -fPIC
SDL_CFLAGS := $(shell pkg-config --cflags sdl2 2>/dev/null)
SDL_LIBS := $(shell pkg-config --libs sdl2 2>/dev/null)
INCLUDES := -I xrick/include
LDFLAGS ?= $(SDL_LIBS)
LDLIBS ?= -lz -lm -pthread

SRCDIR := xrick/src
SRC := $(wildcard $(SRCDIR)/*.c)
OBJDIR := build/obj
BINDIR := build/bin
TARGET := $(BINDIR)/xrick
OBJECTS := $(patsubst $(SRCDIR)/%.c,$(OBJDIR)/%.o,$(SRC))

.PHONY: all build msbuild dotnet gcc clean

# Default: build for Linux with gcc (if available). Use explicit targets for others.
all: gcc

build: msbuild

msbuild:
	@if [ -n "$(MSBUILD)" ]; then \
		msbuild "$(VCXPROJ)" /p:Configuration=$(CONFIG) /p:Platform=$(PLATFORM); \
	elif [ -n "$(DOTNET)" ]; then \
		dotnet build "$(VCXPROJ)" -c $(CONFIG); \
	else \
		echo "No 'msbuild' or 'dotnet' found in PATH. Use 'make gcc' on Linux."; exit 1; \
	fi

dotnet: msbuild

# GCC/Linux build
gcc:
	@if [ -z "$(GCC)" ]; then echo "gcc not found in PATH"; exit 1; fi
	@mkdir -p $(OBJDIR) $(BINDIR)
	@echo "Compiling $(TARGET)..."
	@$(MAKE) -s $(TARGET)

$(TARGET): $(OBJECTS)
	@echo "Linking $@"
	@$(CC) $(CFLAGS) $(SDL_CFLAGS) -o $@ $(OBJECTS) $(LDFLAGS) $(LDLIBS)

$(OBJDIR)/%.o: $(SRCDIR)/%.c
	@mkdir -p $(dir $@)
	@echo "CC $<"
	@$(CC) $(CFLAGS) $(SDL_CFLAGS) $(INCLUDES) -c $< -o $@

clean:
	@rm -rf $(OBJDIR) $(BINDIR)

