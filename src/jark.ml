open ExtList
open ExtString
open Printf
open Datatypes
include Config
include Util
include Usage
open File
open Nrepl

module Jark =
  struct
    open Datatypes

    let nrepl_send env msg  =
      let res = Nrepl.send_msg env msg in
      if notnone res.err then
        printf "%s\n" (strip_fake_newline (us res.err))
      else
        begin
          ignore (strip_fake_newline (us res.out));
          if notnone res.out then printf "%s\n" (strip_fake_newline (us res.out));
          if notnone res.value then begin
            if not (nilp res.value) then
              printf "%s\n" (strip_fake_newline (us res.value));
          end
        end;
        flush stdout

    let node_id env = sprintf "%s:%d" env.host env.port

    let repl_id env = (node_id env) ^ "-repl"

    let make_eval_message env exp =
      { mid = repl_id env; code = exp }

    let clj_string env exp =
      let s = sprintf "(do (in-ns '%s) %s)" env.ns exp in
      Str.global_replace (Str.regexp "\"") "\\\"" s

    let eval code = 
      let env = get_env in
      let expr = clj_string env code in
      nrepl_send env (make_eval_message env expr)

    let require ns =
      eval (sprintf "(require '%s)" ns)

    (* nfa *)

    let eval_ns ns = 
      let env = get_env in
      let f = (sprintf "(jark.ns/dispatch %s)" (qq ns)) in
      nrepl_send env { mid = node_id env; code = f }
      
    let eval_fn ns fn =
      let env = get_env in
      let f = (sprintf "(jark.ns/dispatch %s %s)" (qq ns) (qq fn)) in
      nrepl_send env { mid = node_id env; code = f }

    let eval_nfa ns fn args =
      let env = get_env in
      let s = (String.concat " " args) in
      let f = (sprintf "(jark.ns/dispatch %s %s %s)" (qq ns) (qq fn) s) in
      nrepl_send env { mid = node_id env; code = f }
          
    (* commands *)

    let vm_start port =
      let c = String.concat " " ["java -cp"; cp_boot; "jark.vm"; port; "&"] in
      ignore (Sys.command c);
      getc;
      Unix.sleep 10
        
    let vm_connect host port =
      eval "(jark.vm/stats)"
        
    let do_cp path =
      printf "Adding classpath %s\n" path;
      eval_nfa "jark.cp" "add" [(qq path)]

    let cp_add_file path =
      let apath = (File.abspath path) in
      let f = apath ^ "/" in
      if (File.exists apath) then begin
        if (File.isdir apath) then 
          List.iter (fun x -> do_cp x) (glob (sprintf "%s/*.jar" apath));
        do_cp(apath);
        ()
      end
      else begin
        printf "File not found %s\n" apath;
        ()
      end

     let cp_add path_list =
       List.iter (fun x -> cp_add_file x) path_list;
       ()

    let ns_load path =
      let apath = (File.abspath path) in
      if (File.exists apath) then
        eval (sprintf "(jark.ns/load-clj \"%s\")" apath)
      else begin
        printf "File not found %s\n" apath;
        ()
      end
      
    let wget_cmd ul =
      let url = String.concat " " ul in
      ignore (Sys.command(url))
  
    let install component =
      (try Unix.mkdir cljr 0o740 with Unix.Unix_error(Unix.EEXIST,_,_) -> ());
      (try Unix.mkdir cljr_lib 0o740 with Unix.Unix_error(Unix.EEXIST,_,_) -> ());
      setup_cljr ();
      if standalone then begin
        if (File.exists jar_standalone) then
          pe (jar_standalone ^ " already exists")
        else
          wget_cmd [ wget; url_standalone; "-O"; jar_standalone]
      end
      else begin
        wget_cmd [ wget; url_clojure; "-O"; jar_clojure];
        wget_cmd [ wget; url_clojure_contrib; "-O"; jar_contrib];
        wget_cmd [ wget; url_nrepl; "-O"; jar_nrepl];
        wget_cmd [ wget; url_jark; "-O";  jar_jark]
      end;

      pe "Installed components successfully"

end
