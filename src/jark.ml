module Jark =
  struct

    open Printf
    open Datatypes
    open Config
    module C = Config
    include Usage
    open Gfile
    open Gstr
    open Glist
    open Nrepl

    let nrepl_send env msg  =
      let res = Nrepl.send_msg env msg in
      if Gstr.notnone res.err then
        printf "%s\n" (Gstr.strip_fake_newline (Gstr.us res.err))
      else
        begin
          ignore (Gstr.strip_fake_newline (Gstr.us res.out));
          if Gstr.notnone res.out then printf "%s\n" (Gstr.strip_fake_newline (Gstr.us res.out));
          if Gstr.notnone res.value then begin
            if not (Gstr.nilp res.value) then
              printf "%s\n" (Gstr.strip_fake_newline (Gstr.us res.value));
          end
        end;
        flush stdout

    let nrepl_send_np env msg  () =
      let res = Nrepl.send_msg env msg in
      if (Gstr.notnone res.err) then
          sprintf "%s" (Gstr.strip_fake_newline (Gstr.us res.err))
      else
        begin
          ignore (Gstr.strip_fake_newline (Gstr.us res.out));
          if (Gstr.notnone res.out) then
            sprintf "%s" (Gstr.strip_fake_newline (Gstr.us res.out))
          else if Gstr.notnone res.value then begin
            if not (Gstr.nilp res.value) then
              sprintf "%s" (Gstr.strip_fake_newline (Gstr.us res.value))
            else
              "nil"
          end
          else "nil"
        end

    let node_id env = sprintf "%s:%d" env.host env.port

    let repl_id env = (node_id env) ^ "-repl"

    let make_eval_message env exp =
      { mid = repl_id env; code = exp }

    let clj_string env exp =
      let s = sprintf "(do (in-ns '%s) %s)" env.ns exp in
      Str.global_replace (Str.regexp "\"") "\\\"" s

    let eval code () = 
      let env = C.get_env() in
      let expr = clj_string env code in
      nrepl_send_np env (make_eval_message env expr) ()

    let require ns =
      eval (sprintf "(require '%s)" ns) ()

    let dispatch_fn () =
      match (C.getopt "--json") with 
      | "no"  -> "(jark.ns/dispatch "
      | "yes" -> "(jark.ns/cli-json "
      |  _    -> "(jark.ns/dispatch "

    let nfa n ?(f="nil") ?(a=[]) () =
      let dm = ref "" in
      let env = C.get_env() in
      if f = "nil" then
        dm := (sprintf "(jark.ns/dispatch %s)" (Gstr.qq n)) 
      else if (Glist.is_empty a) then
        dm := (sprintf "(jark.ns/dispatch %s %s)" (Gstr.qq n) (Gstr.qq f))
      else begin
        let sa = String.concat " " (List.map (fun x -> (Gstr.qq x)) a) in
        dm := String.concat " " 
            [dispatch_fn(); (Gstr.qq n); (Gstr.qq f); sa ; ")"]
      end;
      nrepl_send env { mid = node_id env; code = !dm }

    (* commands *)

    let vm_start () =
      C.remove_config();
      let port = C.getopt "--port" in
      let jvm_opts = C.getopt "--jvm-opts" in 
      let log_path = C.getopt "--port" in 
      let c = String.concat " " ["java"; jvm_opts ; "-cp"; C.cp_boot(); "jark.vm"; port; "<&- & 2&>"; log_path] in
      ignore (Sys.command c);
      printf "Started JVM on port %s\n" port
        
    let vm_connect () =
      C.set_env ();
      nfa "jark.vm" ~f:"stats" ()

    let vm_stop () =
      C.remove_config()

    let do_cp path =
      printf "Adding classpath %s\n" path;
      nfa "jark.cp" ~f:"add" ~a:[path] ()

    let cp_add_file path =
      let apath = (Gfile.abspath path) in
      if (Gfile.exists apath) then begin
        if (Gfile.isdir apath) then 
          if not ((C.getopt "--ignore-jars") = "yes") then
            List.iter (fun x -> do_cp x) (Gfile.glob (sprintf "%s/*.jar" apath));
        do_cp(apath);
        ()
      end
      else begin
        if not (Gstr.starts_with path "--") then
          printf "File not found %s\n" apath
      end

    let cp_add path_list =
      List.iter (fun x -> cp_add_file x) path_list;
      ()

    let ns_load path =
      let apath = (Gfile.abspath path) in
      if (Gfile.exists apath) then
        nfa "jark.ns" ~f:"load-clj" ~a:[apath] ()
      else begin
        printf "File not found %s\n" apath;
        ()
      end

    let package_install () =
      let package = C.getopt "--package" in 
      nfa "jark.package" ~f:"install" ~a:[package] ()

    let package_versions () =
      let package = C.getopt "--package" in 
      nfa "jark.package" ~f:"versions" ~a:[package] ()

    let package_latest () =
      let package = C.getopt "--package" in 
      nfa "jark.package" ~f:"latest-version" ~a:[package] ()

    let package_search term () =
      nfa "jark.package" ~f:"search" ~a:[term] ()

    let swank_start () =
      let port = C.getopt "--swank-port" in 
      nfa "jark.swank" ~f:"start" ~a:["0.0.0.0"; port] ()

    let repo_add () =
      let repo_name = C.getopt "--repo-name" in 
      let repo_url = C.getopt "--repo-url" in 
      if repo_name = "none" then 
        Gstr.pe "repo add --repo-name <repo-name> --repo-url <repo-url"
      else if repo_url = "none" then            
        Gstr.pe "repo add --repo-name <repo-name> --repo-url <repo-url"
      else
        nfa "jark.package" ~f:"repo-add" ~a:[repo_name; repo_url] ()

    let get_pid () =
      Gstr.strip (eval (sprintf "(jark.ns/dispatch \"jark.vm\" \"get-pid\")") ())

    let stat_instrument instrument_name () =
      nfa "recon.jvmstat" ~f:"instrument-value" ~a:["localhost"; get_pid() ; instrument_name] ()

    let stat_instruments xs () =
      try
        stat_instrument (List.hd xs) ()
      with Failure("hd") ->
        nfa "recon.jvmstat" ~f:"instrument-names" ~a:["localhost"; get_pid()] ()

    let stat_vms () =
      let remote_host = C.getopt "--remote-host" in 
      nfa "recon.jvmstat" ~f:"vms" ~a:[remote_host] ()
          
    let lein args =
      nfa "leiningen.core" ~f:"-main" ~a:args ()

    let install component =
      (try Unix.mkdir C.cljr 0o740 with Unix.Unix_error(Unix.EEXIST,_,_) -> ());
      (try Unix.mkdir C.cljr_lib 0o740 with Unix.Unix_error(Unix.EEXIST,_,_) -> ());
      C.setup_cljr ();
      if C.standalone then begin
        if (Gfile.exists (C.jar "standalone")) then
          Gstr.pe ((C.jar "standalone") ^ " already exists")
        else
          C.install_standalone()
      end
      else 
        C.install_components();
      Gstr.pe "Installed components successfully"

end
