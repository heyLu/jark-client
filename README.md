A tool to interact with a persistent JVM 

Download the binary here: [http://icylisper.in/jark/downloads.html](http://icylisper.in/jark/downloads.html)

# USAGE

     usage: jark OPTIONS server|repl|<plugin>|<namespace> [<command>|<function>] [<args>]

                 OPTIONS:   [-e|--eval] [-c|--config=<path>]
                            [-h|--host=<hostname>] [-p|--port=<port>]
## On the server:

     jark server install
     jark server start [OPTIONS]
     jark server stop  [OPTIONS]
     jark server load FILE
     jark server info
     jark server uninstall
     jark repl

## On the client:
     
     jark PLUGIN COMMAND [ARGS*]
     jark NAMESPACE FUNCTION [ARGS*]


# BUILD

## GNU/Linux / MacOSX

    brew install https://github.com/toots/homebrew/raw/master/Library/Formula/ocaml-findlib.rb  (on macOSX)
    apt-get install ocaml-findlib (Debian/Ubuntu)
    make deps
    make
    cp build/jark-<ARCH> PATH


## Cross-compilation for Windows

### On Arch:
    packer -S ocaml-mingw32
       
* Point ocamlc and ocamlopt to their mingw32 counterparts
    rm  /usr/bin/ocamlopt 
    rm  /usr/bin/ocamlc
    ln -sf /usr/bin/i486-mingw32-ocamlopt /usr/bin/ocamlopt 
    ln -sf /usr/bin/i486-mingw32-ocamlc /usr/bin/ocamlc
  
* Install dependencies as above (ledit and camlp5) along with the following changes:
  
  * Pass a --no-opt flag to ./configure when building camlp5

  * Edit Makefile in ledit and set the following variables

     OCAMLC=i486-mingw32-ocamlc
     OCAMLOPT=i486-mingw32-ocamlopt
     OTHER_OBJS=/usr/lib/i486-mingw32-ocaml/unix.cma -I `camlp5 -where` gramlib.cma
     OTHER_XOBJS=/usr/lib/i486-mingw32-ocaml/unix.cmxa -I `camlp5 -where` gramlib.cmxa

* run `make exe`


## ON DEBIAN:
There is a debian repository for mingw32-ocaml: http://debian.glondu.net/mingw32/

