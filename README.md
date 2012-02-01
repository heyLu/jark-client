
# jark-client

Jark is a tool to run clojure code on the JVM, interactively and remotely.
It has 2 components - a client written in OCaml and a server written in Clojure/Java. The client is compiled to native code and is extremely tiny (~300KB). 
The client uses the nREPL protocol to transfer clojure data structures over the wire. 


## Installation

### Client

Download the appropriate client binary for your platform:

64-bit:  
[MacOSX](https://github.com/downloads/icylisper/jark-client/jark-0.4-pre-x86_64_macosx.tar.gz)  
[GNU/Linux](https://github.com/downloads/icylisper/jark-client/jark-0.4-pre-x86_64_linux.tar.gz)  

### Server

    jark [--standalone=<true|false> (default:true)] server install 

Currently, the standalone version is packaged with clojure-1.3. To install with clojure-1.2.x do:
           
    jark --standalone=false --clojure-version=1.2.x server install

## Basic usage

    jark [-p PORT] [-j JVM-OPTS] server start
    jark [-h HOST -p PORT] cp add <CLASSPATH>
    jark [-h HOST -p PORT] cp list
    jark [-h HOST -p PORT] vm stat
    jark [-h HOST -p PORT] vm threads [--tree]
    jark [-h HOST -p PORT] ns find <PATTERN>
    jark [-h HOST -p PORT] ns load <FILE>
    jark [-h HOST -p PORT] repl
    and more ...
    jark <NAMESPACE> <FUNCTION> <ARGS>
    and more ...
    jark server stop

Default HOST is localhost and default port is 9000

## Features

#### Remote Clojure REPL

* Jark provides the following REPL commands, besides evaluating Clojure expressions.

         /clear
         /color [true false]
         /config
         /completion [true false]
         /completion-mode [server histfile]
         /cp [list add]
         /debug [true false]
         /inspect var
         /multiline [true false]
         /methods object
         /ns namespace
         /readline [true false]
         /server [version info]
         /vm [info stat]
         /who
         /quit

#### Scripting 
* Standalone Clojure scripts can be written using the #! operator. 

         #!/usr/bin/env jark -h HOST -p PORT
         (clojure code ...)
        
* All Jark commands output JSON for parsing when passed a `--json` option

        jark --json ns find swank 
         => ["swank.commands", "swank.commands.basic", "swank.core" ..]

#### Remote JVM Management
* JVM Performance monitoring `jark vm stat`
* Dynamically add classpath(s) `jark cp add`
* Run on-demand Garbage collection `jark vm gc`

#### Plugins 
* Server-side plugin system. 
* All plugins are written in Clojure
  
        jark plugin list
        jark plugin load <path-to-plugin.clj>

#### Integration with clojure tools
* Provides a default lein plugin that performs lein tasks, interactively and much faster.
* Provides a global package management system using cljr

#### Embeddable Server
 
* Can be embedded in your app/library.

        Add [jark/jark-server "0.4-SNAPSHOT"] to project.clj 
        (require 'clojure.tools.jark.server)
        (clojure.tools.jark.server/start PORT) in your code. 

jark-client can connect to it `jark -h HOST -p PORT N F A`

#### Configurable and easy-to-install
* 32-bit and 64-bit client binaries are available for GNU/Linux, MacOSX and Windows
* Configurable (Edit $PREFIX/jark.conf)

* Code Evaluation
 
        echo CLOJURE-EXPRESSION | jark -s 
        jark -e CLOJURE-EXPRESSION        

* and more ..

## Documentation

https://github.com/icylisper/jark-server/wiki

## Community

User mailing list: https://groups.google.com/group/clojure-jark  
Dev mailing list : https://groups.google.com/group/clojure-jark-dev
    
Catch us on #jark on irc.freenode.net

## Thanks

* Abhijith Gopal
* Ambrose Bonnaire Sergeant
* Chas Emerick (for nREPL)
* Phil Hagelberg (for Leiningen)
* Rich Hickey and team (for Clojure)
    
## License

Copyright © 2012 Martin Demello and Isaac Praveen

Licensed under the EPL. (See the file epl.html.)
