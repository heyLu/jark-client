module Jark =
  struct

    open Printf
    open Datatypes
    open Config
    module C = Config
    open Gfile
    open Gstr
    open Glist
    open Nrepl
    open Gconf
    open Gopt

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
      match (Gopt.getopt "--json" ()) with 
      | "no"  -> "(jark.ns/dispatch "
      | "yes" -> "(jark.ns/cli-json "
      |  _    -> "(jark.ns/dispatch "

    let nfa n ?(f="nil") ?(a=[]) () =
      let dm = ref "" in
      let d  = dispatch_fn() in
      let env = C.get_env() in
      if f = "nil" then
        dm := (sprintf "%s %s)" d (Gstr.qq n)) 
      else if (Glist.is_empty a) then
        dm := (sprintf "%s %s %s)" d (Gstr.qq n) (Gstr.qq f))
      else begin
        let sa = String.concat " " (List.map (fun x -> (Gstr.qq x)) a) in
        dm := String.concat " " 
            [d; (Gstr.qq n); (Gstr.qq f); sa ; ")"]
      end;
      nrepl_send env { mid = node_id env; code = !dm }

end
