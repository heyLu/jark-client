module Jvm =
  struct

    open Config
    open Datatypes
    open Gstr
    open Options
    open Cp
    open Printf
    open Stat
    module C = Config

    let start_cmd jvm_opts port =
      String.concat " " ["java"; jvm_opts ; "-cp"; C.cp_boot (); "jark.vm"; port; "&"]

    let start args =
      let jvm_opts = ref "" in
      let _ = Options.parse args [
        "--jvm-opts", Options.Set_string jvm_opts, "set jvm options"
      ]
      in
      C.remove_config();
      let env = C.get_env () in
      let port = string_of_int env.port in
      let c = start_cmd !jvm_opts port in
      print_endline c;
      ignore (Sys.command c);
      Unix.sleep 3;
      Cp.add [C.java_tools_path ()];
      printf "Started JVM on port %s\n" port
    
    let stop args =
      let pid = Gstr.to_int (Stat.get_pid ()) in
      printf "Stopping JVM with pid: %d\n" pid;
      Unix.kill pid Sys.sigkill;
      C.remove_config ()
  end
