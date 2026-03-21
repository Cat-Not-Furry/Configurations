# dwm version
VERSION = 6.5

# paths
PREFIX = /usr/local
MANPREFIX = ${PREFIX}/share/man
AUTOSTARTDIR = ~/.local/share

# use pkg-config to get X11 flags (portable)
X11INC = $(shell pkg-config --cflags x11)
X11LIB = $(shell pkg-config --libs x11)

# Xinerama, comment if you don't want it
XINERAMALIBS  = -lXinerama
XINERAMAFLAGS = -DXINERAMA

# freetype
FREETYPELIBS = -lfontconfig -lXft
FREETYPEINC = $(shell pkg-config --cflags fontconfig xft)

# includes and libs
INCS = ${X11INC} ${FREETYPEINC}
LIBS = ${X11LIB} ${XINERAMALIBS} ${FREETYPELIBS}

# flags
CPPFLAGS = -D_DEFAULT_SOURCE -D_BSD_SOURCE -D_XOPEN_SOURCE=700L -DVERSION=\"${VERSION}\" ${XINERAMAFLAGS}
CFLAGS   = -std=c99 -pedantic -Wall -Wno-deprecated-declarations -Os ${INCS} ${CPPFLAGS} -Ihodules
LDFLAGS  = ${LIBS}

# compiler and linker
CC = cc
