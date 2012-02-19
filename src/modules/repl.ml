module Repl =
  struct

    open Printf
    open Datatypes
    open Jark
    open Gstr
    open Gsys
    open ANSITerminal
    open Config
    module C = Config

    type completion_mode = Server | Histfile

    let string_of_completion_mode c = match c with
    | Server -> "server"
    | Histfile -> "histfile"

    type repl_config = {
      mutable color           : bool;
      mutable multiline       : bool;
      mutable readline        : bool;
      mutable completion      : bool;
      mutable completion_mode : completion_mode;
    }

    (* have a global repl config, since there is only ever one repl *)
    let config = {
      color           = true;
      multiline       = false;
      readline        = true;
      completion      = false;
      completion_mode = Histfile;
    }

    let bool_of_string s =
      match s with
      | "true"  -> Some true
      | "on"    -> Some true
      | "false" -> Some false
      | "off"   -> Some false
      | _       -> None

    let default_bool s def =
      match bool_of_string s with
      | Some b -> b
      | None   -> def

    (* color printing *)
    let print_string styles str =
      if config.color then
        ANSITerminal.print_string styles str
      else
        Pervasives.print_string str

    let print_line styles str =
      print_string styles (str ^ "\n");
      flush stdout

    let show_config () =
      let fields = [
        "color          ", string_of_bool config.color;
        "readline       ", string_of_bool config.readline;
        "multiline      ", string_of_bool config.multiline;
        "completion     ", string_of_bool config.completion;
        "completion-mode", string_of_completion_mode config.completion_mode
      ]
      in
      let print_field (x,y) =
        print_string [white] x;
        print_string [default] ": ";
        print_line   [green] y
      in
      List.iter print_field fields;
      flush stdout

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
      C.set_env env;
      Gstr.pe (Jark.eval str ());
      flush stdout;
      env

    let repl_cmd env plugin cmd () =
      let str = "(clojure.tools.jark.plugin." ^ plugin ^ "/" ^ cmd ^ ")" in 
      send_cmd env str ()

    let display_help () =
      (* FIXME: Construct the help string dynamically *)
      print_string [cyan] "REPL Commands:\n";
      let lines = Gstr.unlines ["/clear";
                                 "/color [true false]";
                                 "/config";
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

    (* update env from string options *)
    let set_debug env o =
      let d = match bool_of_string o with
      | Some b  -> b
      | None    -> env.debug
      in

      Printf.printf "debug = %s\n" (if d then "true" else "false");
      flush stdout;
      {env with debug = d}

    let set_ns env o =
      Printf.printf "ns: %s\n" o;
      {env with ns = o}

    (* update config fields from string options *)
    let set_color o =
      config.color <- default_bool o config.color;
      print_line [default] ("color: " ^ (string_of_bool config.color))

    let set_completion o =
      config.completion <- default_bool o config.completion;
      print_line [default] ("completion: " ^ (string_of_bool config.completion))

    let set_multiline o =
      config.multiline <- default_bool o config.multiline;
      print_line [default] ("multiline: " ^ (string_of_bool config.multiline))

    let set_readline o =
      config.readline <- default_bool o config.readline;
      print_line [default] ("readline: " ^ (string_of_bool config.readline))

    let set_completion_mode o =
      begin
        config.completion_mode <- match o with
        | "server"   -> Server
        | "histfile" -> Histfile
        | _          -> config.completion_mode
      end;
      print_line [default] (
        "completion-mode: " ^
        (string_of_completion_mode config.completion_mode))

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
      | ["/ns"; o]              -> set_ns env o
      | ["/color"; o]           -> set_color o; env
      | ["/config"]             -> show_config (); env
      | ["/completion"; o]      -> set_completion o; env
      | ["/completion-mode"; o] -> set_completion_mode o; env
      | ["/multiline"; o]       -> set_multiline o; env
      | ["/readline"; o]        -> set_readline o; env
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
        let r = ref (Config.get_env ()) in
        let env = {
          host = !r.host;
          port = !r.port;
          ns   = ns;
          debug = !r.debug
        } in
        r := env;
        while true do
          let str = readline (prompt_of !r) () in
          r := handle !r str ();
        done;
        flush stdout;
      with End_of_file -> print_newline ()

end
