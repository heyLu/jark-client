(*pp $PP *)

module Config =
  struct

    open Printf
    open Datatypes
    open Gsys
    open Gnet
    open Glist
    open Gstr
    open Gfile

    let opts = ref ((Hashtbl.create 0) : (string, string) Hashtbl.t);;

    let user_preferences = Hashtbl.create 0

    let line_stream_of_channel channel =
      Stream.from
        (fun _ -> try Some (input_line channel) with End_of_file -> None)
 
    let cread config () =
      let comments = Str.regexp "#.*" in
      let leading_white = Str.regexp "^[ \t]+" in
      let trailing_white = Str.regexp "[ \t]+$" in
      let equals_delim = Str.regexp "[ \t]*=[ \t]*" in
      let xs = ref [] in
      Stream.iter
        (fun s ->
          let s = Str.replace_first comments "" s in
          let s = Str.replace_first leading_white "" s in
          let s = Str.replace_first trailing_white "" s in
          if String.length s > 0 then
            match Str.bounded_split_delim equals_delim s 2 with
            | [var; value] -> Hashtbl.replace user_preferences var value
            | _ -> failwith s)
        (line_stream_of_channel config);
      List.rev !xs

    let getc () =
      let config_file = (Sys.getenv "HOME") ^ "/.jarkc" in 
      let xs = cread (open_in config_file) in
      xs

    let cljr = 
      if Gsys.is_windows() then
        "c:\cljr"
      else
        (Sys.getenv "HOME") ^ "/.cljr"

    let cljr_lib = 
      if Gsys.is_windows() then
        "c:\cljr\lib"
      else
        (Sys.getenv "HOME") ^ "/.cljr/lib"

    let wget_bin = 
      if Gsys.is_windows() then
        "c:\wget.exe --user-agent jark "
      else
        "wget --user-agent jark "

    let standalone = true

    let java_tools_path = Sys.getenv "JAVA_HOME" ^ "/lib/tools.jar"

    let component c = 
      match c with
      | "clojure"  -> [cljr_lib ^ "/clojure-1.2.1.jar" ;
                        "http://build.clojure.org/releases/org/clojure/clojure/1.2.1/clojure-1.2.1.jar";
                        "1.2.1"]

      | "contrib"   -> [cljr_lib ^ "/clojure-contrib-1.2.0.jar" ;
                         "http://build.clojure.org/releases/org/clojure/clojure-contrib/1.2.0/clojure-contrib-1.2.0.jar";
                         "1.2.0"]

      | "nrepl"     -> [cljr_lib ^ "/tools.nrepl-0.0.5.jar" ;
                         "http://repo1.maven.org/maven2/org/clojure/tools.nrepl/0.0.5/tools.nrepl-0.0.5.jar" ;
                         "0.0.5"]

      | "jark"      -> [cljr_lib ^ "/jark-0.4.jar" ;
                         "http://clojars.org/repo/jark/jark/0.4/jark-0.4.jar";
                         "0.4"]

      | "swank"     -> [cljr_lib ^ "/tools.nrepl-0.0.5.jar" ;
                         "http://clojars.org/repo/swank-clojure/swank-clojure/1.3.2/swank-clojure-1.3.2.jar" ;
                         "0.0.5"]

      | "standalone" -> [cljr_lib ^ "/jark-0.4-standalone.jar" ;
                          "https://github.com/downloads/icylisper/jark-server/jark-0.4-standalone.jar" ;
                          "0.4"]
                                 
      |  _           -> ["none" ; "none" ; "none"]


    let jar c = 
      (List.nth (component c) 0)

    let url c =
      (List.nth (component c) 1)

    let version c =
      (List.nth (component c) 2)

    let cp_boot ()  = 
      if standalone then
        jar "standalone"
      else
        String.concat ":" [ jar "clojure";
                            jar "contrib";
                            jar "nrepl";
                            jar "jark";
                            jar "swank" ]

    let config_dir = 
      if Gsys.is_windows() then
        "c:\jark\\"
      else
        (Sys.getenv "HOME") ^ "/.config/"

    let jark_config_dir = 
      if Gsys.is_windows() then
        "c:\jark\\"
      else
        (Sys.getenv "HOME") ^ "/.config/jark/"

    let setup_cljr () = 
      let file = cljr ^ "/project.clj" in
      let f = open_out(file) in
      let project_clj_string = String.concat 
          " " ["(leiningen.core/defproject cljr.core/cljr-repo";
                "\"1.0.0-SNAPSHOT\"";
                ":description \"cljr is a Clojure REPL and package management system.\"";
                ":dependencies [[org.clojure/clojure \"1.2.0\"]";
                "[org.clojure/clojure-contrib \"1.2.0\"]";
                "[leiningen \"1.1.0\"]";
                "[swank-clojure \"1.3.2\"]]";
                ":classpath [\"./src/\" \"./\"]";
                ":repositories nil)";] in
      fprintf f "%s\n" project_clj_string;
      close_out f

    let install_standalone () =
      Gnet.http_get wget_bin (url "standalone") (jar "standalone")

    let install_components () =
      Gnet.http_get wget_bin (url "clojure") (jar "clojure");
      Gnet.http_get wget_bin (url "contrib") (jar "contrib");
      Gnet.http_get wget_bin (url "nrepl") (jar "nrepl");
      Gnet.http_get wget_bin (url "jark") (jar "jark")
        
    (* config routines *)

    let remove_config () = 
      if (Gfile.exists (jark_config_dir ^ "host")) then 
        Sys.remove(jark_config_dir ^ "host");
      if (Gfile.exists (jark_config_dir ^ "port")) then 
        Sys.remove(jark_config_dir ^ "port");
      ()

    let set k v () =
      let config_dir = (Sys.getenv "HOME") ^ "/.config/" in
      (try Unix.mkdir config_dir 0o740 with Unix.Unix_error(Unix.EEXIST,_,_) -> ());
      (try Unix.mkdir jark_config_dir 0o740 with Unix.Unix_error(Unix.EEXIST,_,_) -> ());
      let file = jark_config_dir ^ k in
      let f = open_out(file) in 
      fprintf f "%s\n" v; 
      close_out f

    let get k () =
      let file = jark_config_dir ^ k in
      let f = open_in file in
      try 
        let line = input_line f in 
        close_in f;
        line
      with e -> 
        close_in_noerr f; 
        raise e
     
    (* options *)
    let host_default = 
      let f = jark_config_dir ^ "host" in
      if (Gfile.exists f) then
        get "host" ()
      else
        "localhost"

    let port_default = 
      let f = jark_config_dir ^ "port" in
      if (Gfile.exists f) then
        get "port" ()
      else
        "9000"

     
    let opt_default opt_name = 
      match opt_name with 
      | "--port"         -> ["-p" ; port_default]
      | "--host"         -> ["-h" ; host_default]
      | "--jvm-opts"     -> ["-o" ; "-Xms64m -Xmx256m -DNOSECURITY=true"]
      | "--log-path"     -> ["-l" ; "/dev/null"]
      | "--package"      -> ["-p" ; "none"]
      | "--swank-port"   -> ["-s" ; "4005"]
      | "--ignore-jars"  -> ["-i" ; "no"]
      | "--json"         -> ["-j" ; "no"]
      | "--repo-name"    -> ["-n" ; "none"]
      | "--repo-url"     -> ["-u" ; "none"]
      | "--remote-host"  -> ["-r" ; "localhost"]
      |  _               -> ["-x" ; "none"]

    let getopt opt_name =
      let alias = (Glist.first (opt_default opt_name)) in
      let h = !opts in 
      if (Hashtbl.mem h opt_name) then
        Hashtbl.find h opt_name
      else if (Hashtbl.mem h alias) then
        Hashtbl.find h alias
      else
        (Glist.last (opt_default opt_name))

    let set_env () =
      let host = (getopt "--host") in
      let port = (getopt "--port") in
      set "host" host ();
      set "port" port ();
      { 
        ns          = "user";
        debug       = false;
        host        = host;
        port        = (Gstr.to_int port)
      }
        
    let get_env () = 
      let host = (getopt "--host") in
      let port = (getopt "--port") in
      {
        ns          = "user";
        debug       = false;
        host        = host;
        port        = (Gstr.to_int port)
      } 

end
