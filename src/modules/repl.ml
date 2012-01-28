
module Repl =
  struct

    open Printf
    open Datatypes
    open Jark
    open Gstr
    open Gsys
    open ANSITerminal

    let prompt_of env = env.ns ^ ">> "

    let readline prompt () =
      let stdin = stdin in
      Ledit.set_prompt prompt;
      Ledit.set_max_len 200;
      Ledit.open_histfile false "/tmp/jark";
      let buf = Buffer.create 4096 in
      let rec loop c = match c with
      | "\n" -> Buffer.contents buf
      | _    -> Buffer.add_string buf c; loop (Ledit.input_char stdin)
      in
      loop (Ledit.input_char stdin)
      
    let show_exc x = Printf.printf "Exception: %s\n%!" (Printexc.to_string x)

    let bad_command () =
      Printf.printf "Bad command\n";
      flush stdout

    let send_cmd env str () =
      Gstr.pe (Jark.eval str ());
      flush stdout;
      env

    let repl_cmd env plugin cmd () =
      let str = "(jark." ^ plugin ^ "/" ^ cmd ^ ")" in 
      send_cmd env str ()

    let display_help () =
      (* FIXME: Construct the help string dynamically *)
      print_string [cyan] "REPL Commands:\n";
      let lines = Gstr.unlines ["/clear";
                                 "/color [true false]";
                                 "/completion [true false]";
                                 "/completion-mode [server histfile]";
                                 "/cp [list add]";
                                 "/debug [true false]";
                                 "/inspect var";
                                 "/multiline [true false]";
                                 "/methods object";
                                 "/ns namespace";
                                 "/readline [true false]";
                                 "/server [version info]";
                                 "/vm [info stat]";
                                 "/who";
                                 "/quit"] in
      print_string [green] lines;
      Printf.printf "\n";
      flush stdout

    let set_debug env o =
      let d = match o with
      | "true"  -> true
      | "on"    -> true
      | "false" -> false
      | "off"   -> false
      | _       -> env.debug
      in
      Printf.printf "debug = %s\n" (if d then "true" else "false");
      flush stdout;
      {env with debug = d}

    let initial_env = {
      ns          = "user";
      debug       = false;
      host        = "localhost";
      port        = 9000
    }

    let handle_cmd env cmd () =
      match Str.bounded_split (Str.regexp " +") cmd 2 with
      | ["/help"]               -> display_help (); env
      | ["/debug"; o]           -> set_debug env o
      | ["/cp"; "list"]         -> repl_cmd env "cp" "list" ()
      | ["/clear"]              -> ignore (Sys.command "clear"); env
      | ["/server"; "version"]  -> repl_cmd env "server" "version" ()
      | ["/server"; "info"]     -> repl_cmd env "server" "info" ()
      | ["/vm"; "version"]      -> repl_cmd env "vm" "version" ()
      | ["/vm"; "stat"]         -> repl_cmd env "vm" "stat" ()
      | ["/readline"; o]        -> set_debug env o
      | ["/ns"; o]              -> set_debug env o
      | ["/quit"]               -> env
      | _                       -> env

    let handle env str () =
      if String.length str == 0 then
        env
      else if Gstr.starts_with str "/" then
        handle_cmd env str ()
      else
        send_cmd env str ()

    let run ns () =
      try
        let r = ref initial_env in
        while true do
          let str = readline (prompt_of !r) () in
          r := handle !r str ();
        done;
        flush stdout;
      with End_of_file -> print_newline ()

end
