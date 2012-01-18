module Jark =
  struct

    open Config
    open Datatypes
    open Gconf
    open Gfile
    open Glist
    open Gopt
    open Gstr
    open Nrepl
    open Printf
    open Response
    module C = Config

    let nrepl_send env fmt msg =
      Response.print_res ~fmt:fmt (Nrepl.send_msg env msg)

    let nrepl_send_np env msg =
      Response.string_of_res (Nrepl.send_msg env msg)

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
      nrepl_send_np env (make_eval_message env expr)

    let require ns =
      eval (sprintf "(require '%s)" ns) ()

    let dispatch_fn () =
      match (Gopt.getopt "--json" ()) with 
      | "no"  -> "(jark.ns/dispatch "
      | "yes" -> "(jark.ns/cli-json "
      |  _    -> "(jark.ns/dispatch "

    let nfa n ?(f="nil") ?(a=[]) ?(fmt=ResText) () =
      let d = dispatch_fn () in
      let env = C.get_env () in
      let qn = Gstr.qq n in
      let qf = Gstr.qq f in
      let sa = String.concat " " (List.map Gstr.qq a) in
      let dm = match f with
      "nil" -> sprintf "%s %s)" d qn
      | _   -> sprintf "%s %s %s %s)" d qn qf sa
      in
      nrepl_send env fmt { mid = node_id env; code = dm }

end
