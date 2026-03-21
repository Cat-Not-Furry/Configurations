# st - simple terminal
# See LICENSE file for copyright and license details.

include config.mk

SRC = codules/st.c codules/x.c
OBJ = ${SRC:.c=.o}

all: st

%.o: %.c
	${CC} -c ${STCFLAGS} -o $@ $<

${OBJ}: config.h config.mk

stt: ${OBJ}
	${CC} -o $@ ${OBJ} ${STLDFLAGS}

clean:
	rm -f stt ${OBJ} st-${VERSION}.tar.gz

dist: clean
	mkdir -p st-${VERSION}
	cp -R Makefile config.h config.mk \
		codules hodules docs patches st-${VERSION}
	tar -cf st-${VERSION}.tar st-${VERSION}
	gzip st-${VERSION}.tar
	rm -rf st-${VERSION}

install: all
	mkdir -p ${DESTDIR}${PREFIX}/bin
	cp -f st ${DESTDIR}${PREFIX}/bin
	chmod 755 ${DESTDIR}${PREFIX}/bin/st
	if [ -z "$(SKIP_MAN)" ]; then \
		mkdir -p ${DESTDIR}${MANPREFIX}/man1; \
		sed "s/VERSION/${VERSION}/g" < docs/st.1 > ${DESTDIR}${MANPREFIX}/man1/st.1; \
		chmod 644 ${DESTDIR}${MANPREFIX}/man1/st.1; \
	fi
	mkdir -p ${DESTDIR}${PREFIX}/share/terminfo
	TERMINFO=${DESTDIR}${PREFIX}/share/terminfo tic -o ${DESTDIR}${PREFIX}/share/terminfo docs/st.info || true

uninstall:
	rm -f ${DESTDIR}${PREFIX}/bin/st \
		${DESTDIR}${MANPREFIX}/man1/st.1

.PHONY: all clean dist install uninstall
