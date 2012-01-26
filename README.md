
jark command line client 


     usage: jark [-v|--version] [-h|--help]
                 [-r|repl] [-e|--eval]
                 [-c|--config=<path>]
                 [-h|--host=<hostname>] [-p|--port=<port>] <module> <command> <args>


On the server:

     jark local install
     jark local server-start [OPTIONS]
     jark local server-stop  [OPTIONS]
     jark local load FILE
     jark local status
     jark local uninstall
     jark repl

On the client:
     
     jark PLUGIN COMMAND [ARGS*]
     jark NAMESPACE FUNCTION [ARGS*]
     

