# dwm - dynamic window manager
# See LICENSE file for copyright and license details.

include config.mk

SRC = codules/exitdwm.c codules/drw.c codules/dwm.c codules/util.c
OBJ = ${SRC:.c=.o}

all: dwm

%.o: %.c
	${CC} -c ${CFLAGS} -o $@ $<

${OBJ}: config.h config.mk

dwm: ${OBJ}
	${CC} -o $@ ${OBJ} ${LDFLAGS}

clean:
	rm -f dwm codules/*.o *.o dwm-${VERSION}.tar.gz
	rm -rf pacman/

dist: clean
	mkdir -p dwm-${VERSION}
	cp -R Makefile config.h config.mk dwm.1 \
		codules hodules core docs patches bar dwm-${VERSION}
	tar -cf dwm-${VERSION}.tar dwm-${VERSION}
	gzip dwm-${VERSION}.tar
	rm -rf dwm-${VERSION}

install: all config.h
	mkdir -p ${DESTDIR}${PREFIX}/bin
	cp -f dwm ${DESTDIR}${PREFIX}/bin
	chmod 755 ${DESTDIR}${PREFIX}/bin/dwm
	if [ -z "$(SKIP_MAN)" ]; then \
		mkdir -p ${DESTDIR}${MANPREFIX}/man1; \
		sed "s/VERSION/${VERSION}/g" < dwm.1 > ${DESTDIR}${MANPREFIX}/man1/dwm.1; \
		chmod 644 ${DESTDIR}${MANPREFIX}/man1/dwm.1; \
	fi
	mkdir -p ${DESTDIR}${AUTOSTARTDIR}/dwm
	cp -r core/autostart.sh ${DESTDIR}${AUTOSTARTDIR}/dwm
	chmod 755 ${DESTDIR}${AUTOSTARTDIR}/dwm/autostart.sh

uninstall:
	rm -f ${DESTDIR}${PREFIX}/bin/dwm \
		${DESTDIR}${MANPREFIX}/man1/dwm.1

pacman: dist
	@mkdir -p pacman
	@cp dwm-${VERSION}.tar.gz pacman/
	@(echo "# Maintainer: Cat-Not-Furry"; \
	  echo "pkgname=dwm"; \
	  echo "pkgver=${VERSION}"; \
	  echo "pkgrel=1"; \
	  echo "pkgdesc='Dynamic window manager'"; \
	  echo "arch=('x86_64')"; \
	  echo "url='https://dwm.suckless.org'"; \
	  echo "license=('MIT')"; \
	  echo "depends=('libx11' 'libxinerama' 'libxft' 'fontconfig')"; \
	  echo "source=('dwm-${VERSION}.tar.gz')"; \
	  echo "sha256sums=('SKIP')"; \
	  echo "build() {"; \
	  echo "  cd \"\$$srcdir\""; \
	  echo "  tar -xzf dwm-${VERSION}.tar.gz"; \
	  echo "  cd dwm-${VERSION}"; \
	  echo "  make"; \
	  echo "}"; \
	  echo "package() {"; \
	  echo "  cd \"\$$srcdir/st-${VERSION}\""; \
	  echo "  make install DESTDIR=\"\$$pkgdir\""; \
	  echo "}"; \
	) > pacman/PKGBUILD
	@echo "PKGBUILD creado en pacman/ con el tarball dwm-${VERSION}.tar.gz"
	@echo "For install use:"
	@echo "  cd pacman"
	@echo "  makepkg -s"
	@echo "  sudo pacman -U dwm-${VERSION}-x86_64.pkg.tar.zst"

.PHONY: all clean dist install uninstall pacman
