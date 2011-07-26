 (*pp $PP *)

open Gstr

(* command usage *)
let vm_usage = 
  Gstr.unlines ["usage: jark vm <command> <args> [options]";
                 "Available commands for 'vm' module:\n";
                 "    start     [-p|--port=<9000>] [-j|--jvm-opts=<opts>] [--log=<path>]" ;
                 "              Start a local Jark server. Takes optional JVM options as a \" delimited string\n" ;
                 "    stop      [-n|--name=<vm-name>]";
                 "              Shuts down the current instance of the JVM\n" ;
                 "    connect   [-a|--host=<localhost>] [-p|--port=<port>] [-n|--name=<vm-name>]" ;
                 "              Connect to a remote JVM\n" ;
                 "    stat      [--instruments] [--instrument-value <name>]\n" ;
                 "    threads   Print a list of JVM threads\n" ;
                 "    uptime    uptime of the current instance of the JVM\n" ;
                 "    gc        Run garbage collection on the current instance of the JVM" ]

let repo_usage =
  Gstr.unlines ["usage: jark [options] repo <command> <args>";
                 "Available commands for 'repo' module:\n";
                 "    list      List current repositories\n" ;
                 "    add       --repo-name <repo-name> --repo-url <repo-url>" ;
                 "              Add repository\n" ;
                 "    remove    --repo-name <repo-name>" ;
                 "              Remove repository"]

let swank_usage =
  Gstr.unlines ["usage: jark [options] swank <command> <args>";
                 "Available commands for 'swank' module:\n";
                 "    start     [-s|--swank-port 4005]" ; 
                 "              Start a swank server on given port\n" ;
                 "    stop      Stop an instance of the server"]

let cp_usage = 
  Gstr.unlines ["usage: jark [options] cp <command> <args>";
                 "Available commands for 'cp' module:\n";
                 "    list      List the classpath for the current instance of the JVM\n" ;
                 "    add       path+ [--ignore-jars]" ;
                 "              Add to the classpath for the current instance of the JVM"]

let ns_usage = 
  Gstr.unlines ["usage: jark [options] ns <command> <args>";
                 "Available commands for 'ns' module:\n";
                 "    list      [prefix]" ;
                 "              List all namespaces in the classpath. Optionally takes a namespace prefix\n" ;
                 "    load      [--env=<string>] file" ;
                 "              Loads the given clj file, and adds relative classpath"]

let package_usage = 
  Gstr.unlines ["usage: jark [options] package <command> <args>";
                 "Available commands for 'package' module:\n";
                 "    install    -p|--package <package> [-v|--version <version>]" ;
                 "               Install the relevant version of package from clojars\n" ;
                 "    uninstall  -p|--package <package>" ;
                 "               Uninstall the package\n" ;
                 "    versions   -p|--package <package>" ;
                 "               List the versions of package installed\n" ;
                 "    deps       -p|--package <package> [-v|--version <version>]" ;
                 "               Print the library dependencies of package\n" ;
                 "    search     -p|--package <package>" ;
                 "               Search clojars for package\n" ;
                 "    list       List all packages installed\n" ;
                 "    latest     -p|--package <package>" ;
                 "               Print the latest version of the package" ]

let stat_usage = 
  Gstr.unlines ["usage: jark stat <command> <args>";
                 "Available commands for 'stat' module:\n";
                 "    instruments    [prefix]" ;
                 "                   List all available instruments. Optionally takes a regex\n" ;
                 "    instrument     <instrument-name>" ;
                 "                   Print the value for the given instrument name"]

let usage =
  Gstr.unlines ["usage: jark [-v|--version] [-h|--help]" ;
                 "            [-r|repl] [-e|--eval] [-i|--install|install]" ;
                 "            [-c|--config=<path>]";
                 "            [-h|--host=<hostname>] [-p|--port=<port>] <module> <command> <args>" ;
                 "";
                 "The most commonly used jark modules are:" ;
                 "    cp       list add" ;
                 "    doc      search examples comments" ;
                 "    lein     <task(s)>";
                 "    ns       list load run" ;
                 "    package  install uninstall versions deps search installed latest" ;
                 "    repo     list add remove" ;
                 "    stat     instruments instrument vms mem";
                 "    swank    start stop" ;
                 "    vm       start connect stop uptime threads gc";
                 "";
                 "See 'jark <module>' for more information on a specific module."]

let connection_usage = 
  Gstr.unlines ["Cannot connect to the JVM on localhost:9000" ;
                 "Try vm connect --host <HOST> --port <PORT>";
                 "or specify --host / --port flags in the command"]
