module Vm =
  struct

    open Printf
    open Glist
    open Gstr
    open Jark
    open Config
    module C = Config

    open Cp
    open Gconf
    open Stat
    open Gopt

    let usage = 
      Gstr.unlines ["usage: jark vm <command> <args> [options]";
                     "Available commands for 'vm' module:\n";
                     "    start     [-p|--port=<9000>] [-j|--jvm-opts=<opts>] [--log=<path>]" ;
                     "              Start a local Jark server. Takes optional JVM options as a \" delimited string\n" ;
                     "    stop      [-n|--name=<vm-name>]";
                     "              Shuts down the current instance of the JVM\n" ;
                     "    connect   [-a|--host=<localhost>] [-p|--port=<port>] [-n|--name=<vm-name>]" ;
                     "              Connect to a remote JVM\n" ;
                     "    threads   Print a list of JVM threads\n" ;
                     "    uptime    uptime of the current instance of the JVM\n" ;
                     "    gc        Run garbage collection on the current instance of the JVM"]

    let start () =
      C.remove_config();
      let port = Gopt.getopt "--port" () in
      let jvm_opts = Gopt.getopt "--jvm-opts" () in 
      let c = String.concat " " ["java"; jvm_opts ; "-cp"; C.cp_boot(); "jark.vm"; port; "&"] in
      ignore (Sys.command c);
      Unix.sleep 3;
      Cp.add [C.java_tools_path()];
      printf "Started JVM on port %s\n" port
        
    let connect () =
      let _ = C.set_env () in
      Jark.nfa "jark.vm" ~f:"stats" ()

    let stop () =
      let pid = Gstr.to_int (Stat.get_pid()) in
      printf "Stopping JVM with pid: %d\n" pid;
      Unix.kill pid Sys.sigkill;
      C.remove_config()

    let dispatch cmd arg =
      Gopt.opts := (Glist.list_to_hashtbl arg);
      match cmd with
      | "usage"   -> Gstr.pe usage
      | "start"   -> start()
      | "stop"    -> stop()
      | "connect" -> connect()
      | "stat"    -> Jark.nfa "jark.vm" ~f:"stats" ()
      | "uptime"  -> Jark.nfa "jark.vm" ~f:"uptime" ()
      | "gc"      -> Jark.nfa "jark.vm" ~f:"gc" ()
      | "threads" -> Jark.nfa "jark.vm" ~f:"threads" ()
      |  _        -> Gstr.pe usage 


end
