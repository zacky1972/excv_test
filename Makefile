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

LDFLAGS += -shared
CFLAGS ?= -std=c11 -Ofast -Wall -Wextra -Wno-unused-parameter

ifeq ($(CROSSCOMPILE),)
	ifneq ($(OS),Windows_NT)
		LDFLAGS += -fPIC
		CFLAGS += -fPIC
		ifeq ($(shell uname),Darwin)
			LDFLAGS += -dynamiclib -undefined dynamic_lookup
		endif
	endif
endif

NIF=priv/libnif.so

all: priv $(NIF)

priv:
	mkdir -p priv

$(NIF): c_src/libnif.c
	$(CC) $(ERL_CFLAGS) $(CFLAGS) \
		-o $@ $< \
		$(ERL_LDFLAGS) $(LDFLAGS)

clean:
	$(RM) $(NIF)
