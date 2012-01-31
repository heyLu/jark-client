module Jark =
  struct

    open Config
    open Datatypes
    open Gstr
    open Nrepl
    open Printf
    open Response
    module C = Config

    (* evaluate msg, print output+value to stdout *)
    (* pretty-print value based on fmt *)
    (* used by the cli client to display hashes/lists from the server *)
    let nrepl_send env fmt msg =
      Response.print_res ~fmt:fmt (Nrepl.send_msg env msg)

    (* evaluate msg, return output+value as string *)
    (* used by the repl client *)
    let nrepl_send_np ~out ~value env msg =
      Response.string_of_res ~out:out ~value:value (Nrepl.send_msg env msg)

    let node_id env = sprintf "%s:%d" env.host env.port

    let repl_id env = (node_id env) ^ "-repl"

    let make_eval_message env exp =
      { mid = repl_id env; code = exp }

    let clj_string env exp =
      let s = sprintf "(do (in-ns '%s) %s)" env.ns exp in
      Str.global_replace (Str.regexp "\"") "\\\"" s

    let eval code ?(out=true) ?(value=true) () =
      let env = C.get_env() in
      let expr = clj_string env code in
      let msg = make_eval_message env expr in
      nrepl_send_np ~out:out ~value:value env msg

    let require ns =
      eval (sprintf "(require '%s)" ns) ()

    let dispatch_fn () = "(clojure.tools.jark.server/dispatch "
      match (Gopt.getopt "--json" ()) with 
      | "no"  -> "(clojure.tools.jark.server/dispatch "
      | "yes" -> "(clojure.tools.jark.server/cli-json "
      |  _    -> "(clojure.tools.jark.server/dispatch "

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

    let dispatch args =
      match args with
        [] -> ()
      | [ns] -> nfa ns ()
      | ns :: f :: rest -> nfa ns ~f:f ~a:rest ()

end
