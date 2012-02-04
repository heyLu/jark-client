
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

    jark server install 

For a system-wide install

    jark --install-root /usr/lib/clojure server install 

Currently, the standalone version is packaged with clojure-1.3. To install with clojure-1.2.x do:
           
    jark --clojure-version 1.2.1 server install
    (or jark -c 1.2.1 server install)
    jark -c 1.3.0 server install

Once the jars are downloaded, you can start multiple servers with different clojure versions

    jark -c 1.2.1 -p 9001 server start 
    jark -c 1.3.0 -p 9002 server start 

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
