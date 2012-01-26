
jark command line client 


     usage: jark [-v|--version] [-h|--help]
                 [-r|repl] [-e|--eval]
                 [-c|--config=<path>]
                 [-h|--host=<hostname>] [-p|--port=<port>] <module> <command> <args>


On the server:

     jark server install
     jark server start [OPTIONS]
     jark server stop  [OPTIONS]
     jark server load FILE
     jark server status
     jark server uninstall
     jark repl

On the client:
     
     jark PLUGIN COMMAND [ARGS*]
     jark NAMESPACE FUNCTION [ARGS*]
     

