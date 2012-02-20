module Jvm =
  struct

    open Config
    open Datatypes
    open Gstr
    open Options
    open Printf
    open Jark
    module C = Config

    let cp_boot () =
      C.read_config ();
      C.classpath ()

    let start_cmd jvm_opts port log_file =
      String.concat " " ["java"; jvm_opts ; "-cp"; cp_boot (); "clojure.tools.jark.server"; port; " "; "&> "; log_file; " &"]

    let start args =
      let opts = C.get_server_opts () in
      let jvm_opts = opts.jvm_opts in
      let env = C.get_env () in
      let port = string_of_int env.port in
      let c = start_cmd jvm_opts port opts.log_file in
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
