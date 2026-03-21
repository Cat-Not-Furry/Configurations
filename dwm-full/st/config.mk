# st version
VERSION = 0.9.2

# paths
PREFIX = /usr/local
MANPREFIX = $(PREFIX)/share/man

PKG_CONFIG = pkg-config

# includes and libs
INCS = -I. -Ihodules \
       $(shell $(PKG_CONFIG) --cflags fontconfig) \
       $(shell $(PKG_CONFIG) --cflags freetype2)
LIBS = -lm -lrt -lX11 -lutil -lXft -lXrender \
       $(shell $(PKG_CONFIG) --libs fontconfig) \
       $(shell $(PKG_CONFIG) --libs freetype2)

# flags
STCPPFLAGS = -DVERSION=\"$(VERSION)\" -D_XOPEN_SOURCE=600
STCFLAGS = $(INCS) $(STCPPFLAGS) $(CPPFLAGS) $(CFLAGS)
STLDFLAGS = $(LIBS) $(LDFLAGS)

# compiler and linker
CC = cc
