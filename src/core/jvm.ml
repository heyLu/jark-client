module Jvm =
  struct

    open Config
    open Datatypes
    open Gstr
    open Options
    open Printf
    open Jark
    module C = Config

    let start_cmd jvm_opts port =
      String.concat " " ["java"; jvm_opts ; "-cp"; C.cp_boot (); "clojure.tools.jark.server"; port; "&"]

    let start args =
      let jvm_opts = ref C.global_opts.jvm_opts in
      let _ = Options.parse args [
        "--jvm-opts", Options.Set_string jvm_opts, "set jvm options"
      ]
      in
      let env = C.get_env () in
      let port = string_of_int env.port in
      let c = start_cmd !jvm_opts port in
      print_endline c;
      ignore (Sys.command c);
      Unix.sleep 3;
      printf "Started JVM on port %s\n" port
    
    let get_pid () =
      let msg = "(clojure.tools.jark.server/dispatch \"clojure.tools.jark.server\" \"pid\")" in
      let pid = Gstr.strip (Jark.eval ~out:true ~value:false msg ()) in
      Gstr.maybe_int pid

    let stop args =
      (* FIXME: Ensure that stop is issued only on the server *)
      match get_pid () with
      | None -> print_endline "Could not get pid of JVM"
      | Some pid ->
          begin
            printf "Stopping JVM with pid: %d\n" pid;
            Unix.kill pid Sys.sigkill;
          end
  end
