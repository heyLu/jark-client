
VERSION = 0.4-pre

ARCH = $(shell uname)-$(shell uname -m)

PREFIX=debian/jark/usr

BIN_NAME = jark

OLIB = /usr/lib/ocaml
WLIB = /usr/lib/i486-mingw32-ocaml
WGET = wget --no-check-certificate -O -


# download and make dependencies within the project directory
TOP = $(shell pwd)
DEP = $(TOP)/deps
LEDIT = $(TOP)/src/lib/ledit
GUTILS = src/lib/gutils
NREPL = src/lib/nrepl

# External Deps
DEPLIBS = $(DEP)/lib
ANSITERM = $(DEPLIBS)/ANSITerminal-0.6/_build
CAMLP5 = $(DEPLIBS)/ocaml/camlp5


WIN_LIBS = $(WLIB)/unix,$(WLIB)/bigarray,$(WLIB)/str,$(WLIB)/nums,$(WLIB)/camlp5/camlp5,$(WLIB)/camlp5/gramlib,$(WLIB)/ledit/ledit

LIBS = unix,bigarray,str,nums,$(CAMLP5)/camlp5,$(CAMLP5)/gramlib,$(ANSITERM)/ANSITerminal,$(LEDIT)/ledit

OCAMLBUILD = ocamlbuild -j 2 -quiet  -I $(GUTILS) -I $(NREPL) -I src -I src/plugins  -lflags -I,/usr/lib/ocaml/pcre  \
           -lflags -I,$(CAMLP5)  -lflags -I,$(ANSITERM) -cflags -I,$(ANSITERM) -cflags  -I,$(LEDIT) -lflags  -I,$(LEDIT)

WOCAMLBUILD = ocamlbuild -j 2 -quiet -I $(GUTILS) -I src -I src/core -I src/plugins -lflags -I,$(WLIB)/pcre  \
           -lflags -I,$(WLIB)/camlp5 -cflags  -I,$(WLIB)/ledit

all:: native

native :
	cd $(LEDIT)  && make && make ledit.cmxa 
	$(OCAMLBUILD) -libs $(LIBS) main.native
	if [ ! -d build/$(ARCH) ]; then mkdir -p build/$(ARCH); fi
	cp _build/src/main.native build/$(ARCH)/$(BIN_NAME)
	rm -rf _build

upx :
	$(OCAMLBUILD) -libs $(LIBS) main.native
	if [ ! -d build/$(ARCH) ]; then mkdir -p build/$(ARCH); fi
	cp _build/src/main.native build/$(ARCH)/$(BIN_NAME)-un
	rm build/$(ARCH)/$(BIN_NAME)
	upx --brute --best -f -o build/$(ARCH)/$(BIN_NAME) build/$(ARCH)/$(BIN_NAME)-un
	rm -f build/$(BIN_NAME)-un
	rm -rf _build

byte : 
	$(OCAMLBUILD) -libs $(LIBS) main.byte
	cp _build/src/main.byte jark.byte


native32 :
	$(OCAMLBUILD) -libs $(LIBS) -ocamlopt "ocamlopt.32" main.native
	cp _build/src/main.native jark.native
	rm -rf _build

gprof :
	$(OCAMLBUILD) -libs $(LIBS) -ocamlopt "ocamlopt -p" main.native
	cp _build/src/main.native jark.native

exe :
	$(WOCAMLBUILD) -libs $(WIN_LIBS) -ocamlc i486-mingw32-ocamlc -ocamlopt i486-mingw32-ocamlopt  main.native
	mkdir -p build/Win-i386
	cp _build/src/main.native build/Win-i386/jark.exe
	rm -rf _build

clean::
	rm -f *.cm[iox] *~ .*~ src/*~ #*#
	rm -rf html
	rm -f jark.{exe,native,byte}
	rm -f gmon.out
	rm -f jark*.tar.{gz,bz2}
	rm -rf jark
	rm -f ~/src/lib/nrepl/*.cm[iox]
	rm -f ~/src/lib/gutils/*.cm[iox]
	ocamlbuild -clean
	cd $(LEDIT)  && make clean

install : native
	mkdir -p $(PREFIX)/bin
	install -m 0755 build/$(ARCH)/$(BIN_NAME) $(PREFIX)/bin/

up:
	cd upload && upload.rb jark-$(VERSION)-x86_64.tar.gz icylisper/jark-client

tar:
	rm -rf upload/jark-$(VERSION)-$(ARCH)
	mkdir -p upload
	cd upload && mkdir jark-$(VERSION)-$(ARCH)
	cp README.md upload/jark-$(VERSION)-$(ARCH)/README
	cp build/$(ARCH)/jark upload/jark-$(VERSION)-$(ARCH)/jark
	cd upload && tar zcf jark-$(VERSION)-$(ARCH).tar.gz jark-$(VERSION)-$(ARCH)/*

deb:
	fakeroot debian/rules clean
	fakeroot debian/rules binary

deps: ansiterminal camlp5

ansiterminal:
	if [ ! -e $(ANSITERM)/ANSITerminal.cmxa ]; then \
		mkdir -p $(DEPLIBS) ;\
		cd $(DEPLIBS) && $(WGET) https://forge.ocamlcore.org/frs/download.php/610/ANSITerminal-0.6.tar.gz 2> /dev/null | tar xzvf - ;\
		cd $(DEPLIBS)/ANSITerminal-0.6 && ocaml setup.ml -configure && ocaml setup.ml -build ;\
	fi

camlp5:
	if [ ! -e $(CAMLP5)/camlp5.cmxa ]; then \
		mkdir -p $(DEPLIBS) ; \
		cd $(DEPLIBS) && $(WGET) http://pauillac.inria.fr/~ddr/camlp5/distrib/src/camlp5-6.02.3.tgz 2> /dev/null | tar xzvf - ; \
		cd camlp5-6.02.3 && ./configure --prefix $(DEP) && make world.opt && make install ;\
		rm -rf $(DEPLIBS)/camlp5-6.02.3 ;\
	fi

LINUX_64_HOST=vagrant@33.33.33.20
LINUX_32_HOST=vagrant@33.33.33.21
WIN_32_HOST=vagrant@33.33.33.22

linux-64: deb
	ssh ${LINUX_64_HOST} "cd ~/jark-client && git pull && make && make tar"
	scp ${LINUX_64_HOST}:~/jark-client/upload/jark-${VERSION}-Linux-x86_64.tar.gz upload/
	scp ${LINUX_64_HOST}:~/*.deb upload/

linux-32:
	ssh ${LINUX_32_HOST} "cd ~/jark-client && git pull && make && make tar"
	scp ${LINUX_32_HOST}:~/jark-client/upload/jark-${VERSION}-Linux-i386.tar.gz upload/
