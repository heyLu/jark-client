
# jark-client

Jark is a tool to run clojure code on the JVM, interactively and remotely.
It has 2 components - a client written in OCaml and a server written in Clojure/Java. The client is compiled to native code and is extremely tiny (~300KB). 
The client uses the nREPL protocol to transfer clojure data structures over the wire. 

See https://github.com/icylisper/jark-server/wiki/Getting-started

More documentation at: https://github.com/icylisper/jark-server/wiki

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

Copyright © 2012 Martin DeMello and Isaac Praveen

Licensed under the EPL. (See the file epl.html.)
