
# jark-client

Jark is a tool to run clojure code on the JVM, interactively and remotely.
It has 2 components - a client written in OCaml and a server written in Clojure/Java. The client is compiled to native code and is extremely tiny (~300KB). 
The client uses the nREPL protocol to transfer clojure data structures over the wire. 

Project page:  http://icylisper.in/jark

Downloads: http://icylisper.in/jark/downloads.html

## Community

User mailing list: https://groups.google.com/group/clojure-jark  
Dev mailing list : https://groups.google.com/group/clojure-jark-dev
    
Catch us on #jark on irc.freenode.net

## Authors

* Martin DeMello
* Isaac Praveen

Contributors:

* Lucas Stadler  
* Abhijith Gopal

## Thanks

* Abhijith Gopal
* Ambrose Bonnaire Sergeant
* Chas Emerick (for nREPL)
* Phil Hagelberg (for Leiningen)
* Rich Hickey (for Clojure)
    
## License

Copyright © 2012 Martin DeMello and Isaac Praveen

Licensed under the GPLv2
