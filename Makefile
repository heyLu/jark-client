
VERSION = 0.4-pre

ARCH = $(shell uname)-$(shell uname -m)

BIN_NAME = jark

OLIB = /usr/lib/ocaml
WLIB = /usr/lib/i486-mingw32-ocaml
WGET = wget --no-check-certificate -O -


# download and make dependencies within the project directory
TOP = $(shell pwd)
DEP = $(TOP)/deps
DEPLIBS = $(DEP)/lib
LEDIT = $(DEPLIBS)/ocaml/ledit
ANSITERM = $(DEPLIBS)/ANSITerminal-0.6/_build
CAMLP5 = $(DEPLIBS)/ocaml/camlp5

WIN_LIBS = $(WLIB)/unix,$(WLIB)/bigarray,$(WLIB)/str,$(WLIB)/nums,$(WLIB)/camlp5/camlp5,$(WLIB)/camlp5/gramlib,$(WLIB)/ledit/ledit

LIBS = unix,bigarray,str,nums,$(CAMLP5)/camlp5,$(CAMLP5)/gramlib,$(LEDIT)/ledit,$(ANSITERM)/ANSITerminal

OCAMLBUILD = ocamlbuild -j 2 -quiet -I src/utils -I src/core -I src -I src/modules  -lflags -I,/usr/lib/ocaml/pcre  \
           -lflags -I,$(CAMLP5) -cflags  -I,$(LEDIT) -lflags -I,$(ANSITERM) -cflags -I,$(ANSITERM)

WOCAMLBUILD = ocamlbuild -j 2 -quiet -I src/utils -I src -I src/core -I src/modules -lflags -I,$(WLIB)/pcre  \
           -lflags -I,$(WLIB)/camlp5 -cflags  -I,$(WLIB)/ledit

all:: native


native :
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
	ocamlbuild -clean

up:
	cd upload && upload.rb jark-$(VERSION)-x86_64.tar.gz icylisper/jark-client

tar:
	rm -rf upload/jark-$(VERSION)-$(ARCH)
	mkdir -p upload
	cd upload && mkdir jark-$(VERSION)-$(ARCH)
	cp README.md upload/jark-$(VERSION)-$(ARCH)/README
	cp build/$(ARCH)/jark upload/jark-$(VERSION)-$(ARCH)/jark
	cd upload && tar zcf jark-$(VERSION)-$(ARCH).tar.gz jark-$(VERSION)-$(ARCH)/*

deps: ansiterminal camlp5 ledit

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

ledit:
	if [ ! -e $(LEDIT)/ledit.cmxa ]; then \
		mkdir -p $(DEPLIBS) ; \
		cd $(DEPLIBS) && $(WGET) http://pauillac.inria.fr/~ddr/ledit/distrib/src/ledit-2.03.tgz 2> /dev/null | tar xzvf - ; \
		cd ledit-2.03 && make && make ledit.cmxa ; \
		mv $(DEPLIBS)/ledit-2.03 $(DEPLIBS)/ocaml/ledit ; \
	fi

LINUX_64_HOST=vagrant@33.33.33.20
LINUX_32_HOST=vagrant@33.33.33.21
WIN_32_HOST=vagrant@33.33.33.22

linux-64:
	ssh ${LINUX_64_HOST} "cd ~/jark-client && git pull && make && make tar"
	scp ${LINUX_64_HOST}:~/jark-client/upload/jark-${VERSION}-Linux-x86_64.tar.gz upload/

linux-32:
	ssh ${LINUX_32_HOST} "cd ~/jark-client && git pull && make && make tar"
	scp ${LINUX_32_HOST}:~/jark-client/upload/jark-${VERSION}-Linux-i386.tar.gz upload/
