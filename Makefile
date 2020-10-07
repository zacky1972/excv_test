.phony: all clean

ifeq ($(ERL_EI_INCLUDE_DIR),)
	ERL_ROOT_DIR = $(shell erl -eval "io:format(\"~s~n\", [code:root_dir()])" -s init stop -noshell)
	ifeq ($(ERL_ROOT_DIR),)
		$(error Could not find the Erlang installation. Check to see that 'erl' is in your PATH)
	endif
	ERL_EI_INCLUDE_DIR = "$(ERL_ROOT_DIR)/usr/include"
	ERL_EI_LIBDIR = "$(ERL_ROOT_DIR)/usr/lib"
endif

# Set Erlang-specific compile and linker flags
ERL_CFLAGS ?= -I$(ERL_EI_INCLUDE_DIR)
ERL_LDFLAGS ?= -L$(ERL_EI_LIBDIR)

LDFLAGS += -shared -lstdc++
CFLAGS ?= -std=c11 -Ofast -Wall -Wextra -Wno-unused-parameter
CXXFLAGS ?= -std=c++11 -Ofast -Wall -Wextra -Wno-unused-parameter

ifeq ($(CROSSCOMPILE),)
	ifneq ($(OS),Windows_NT)
		LDFLAGS += -fPIC
		CFLAGS += -fPIC
		CXXFLAGS += -fPIC

		ifeq ($(shell uname),Darwin)
			LDFLAGS += -dynamiclib -undefined dynamic_lookup
		endif
	endif
endif

NIF=priv/libnif.so

C_SRCS := c_src/libnif.c
C_OBJS := $(C_SRCS:c_src/%.c=obj/%.o)
C_DEPS := $(C_SRCS:c_src/%.c=obj/%.d)

CXX_SRCS := c_src/cvtest.cpp
CXX_OBJS := $(CXX_SRCS:c_src/%.cpp=obj/%.o)
CXX_DEPS := $(CXX_SRCS:c_src/%.cpp=obj/%.d)

$(warning C_OBJS = $(C_OBJS))
$(warning C_DEPS = $(C_DEPS))
$(warning CXX_OBJS = $(CXX_OBJS))
$(warning CXX_DEPS = $(CXX_DEPS))

OLD_SHELL := $(SHELL)
SHELL = $(warning [Making: $@] [Dependencies: $^] [Changed: $?])$(OLD_SHELL)

all: priv obj $(NIF)


priv:
	mkdir -p priv


obj:
	mkdir -p obj


$(NIF): $(C_OBJS) $(CXX_OBJS)
	$(CXX) -o $@ $^ $(ERL_LDFLAGS) $(LDFLAGS)

$(C_DEPS): obj/%.d: c_src/%.c
	$(CC) $(ERL_CFLAGS) $(CFLAGS) $< -MM -MP -MF $@

$(C_OBJS): obj/%.o: c_src/%.c obj/%.d
	$(CC) -c $(ERL_CFLAGS) $(CFLAGS) -o $@ $<

$(CXX_DEPS): obj/%.d: c_src/%.cpp
	$(CXX) $(ERL_CFLAGS) $(CXXFLAGS) $< -MM -MP -MF $@

$(CXX_OBJS): obj/%.o: c_src/%.cpp obj/%.d
	$(CXX) -c $(ERL_CFLAGS) $(CXXFLAGS) -o $@ $<

include $(shell ls $(C_DEPS) 2>/dev/null)

clean:
	$(RM) $(NIF) obj/*
