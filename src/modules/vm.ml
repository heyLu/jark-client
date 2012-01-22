module Vm =
  struct

    open Datatypes
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
    open Plugin

    let registry = Plugin.create ()
    let register_fn = Plugin.register_fn registry
    let alias_fn = Plugin.alias_fn registry

    let show_usage args = Plugin.show_usage registry "vm"

    let start_cmd jvm_opts port =
      String.concat " " ["java"; jvm_opts ; "-cp"; C.cp_boot (); "jark.vm"; port; "&"]

    let start args =
      C.remove_config();
      let port = Gopt.getopt "--port" () in
      let jvm_opts = Gopt.getopt "--jvm-opts" () in
      let c = start_cmd jvm_opts port in
      print_endline c;
      ignore (Sys.command c);
      Unix.sleep 3;
      Cp.add [C.java_tools_path ()];
      printf "Started JVM on port %s\n" port

    let connect args =
      Jark.nfa "jark.vm" ~f:"stats" ()

    let stop args =
      let pid = Gstr.to_int (Stat.get_pid ()) in
      printf "Stopping JVM with pid: %d\n" pid;
      Unix.kill pid Sys.sigkill;
      C.remove_config ()

    let gc args = Jark.nfa "jark.vm" ~f:"gc" ()

    let stat args = Jark.nfa "jark.vm" ~f:"stats" ~fmt:ResHash ()

    let threads args = Jark.nfa "jark.vm" ~f:"threads" ~fmt:ResList ()

    let uptime args = Jark.nfa "jark.vm" ~f:"uptime" ()

    let _ =
      register_fn "start" start [
        "[-p|--port=<9000>] [-j|--jvm-opts=<opts>] [--log=<path>]" ;
        "Start a local Jark server. Takes optional JVM options as a \" delimited string"];

      register_fn "stop" stop [
        "[-n|--name=<vm-name>]";
        "Shuts down the current instance of the JVM"];

      register_fn "connect" connect [
        "[-a|--host=<localhost>] [-p|--port=<port>] [-n|--name=<vm-name>]" ;
        "Connect to a remote JVM"];

      register_fn "stat" stat ["Print JVM stats"];

      register_fn "threads" threads ["Print a list of JVM threads"];

      register_fn "uptime" uptime ["Uptime of the current instance of the JVM"];

      register_fn "gc" gc ["Run garbage collection on the current instance of the JVM"]

    let dispatch cmd arg =
      Gopt.opts := (Glist.list_to_hashtbl arg);
      Plugin.dispatch registry cmd arg

end
