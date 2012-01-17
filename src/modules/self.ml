module Self =
  struct

    open Glist
    open Gstr
    open Gfile
    open Jark
    open Config
    module C = Config
    open Stat
    open Gopt

    let usage =
      Gstr.unlines ["usage: jark [options] self <command> <args>";
                     "Available commands for 'self' module:\n";
                     "    install     [--no-standalone] [--force]" ; 
                     "    uninstall ";
                     "    update ";
                     "    status      VM connection status"]

    let show_usage () = Gstr.pe usage

    let install () =
      (try Unix.mkdir Config.cljr 0o740 with Unix.Unix_error(Unix.EEXIST,_,_) -> ());
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

    let status () =
      let host = Gopt.getopt "--host" () in
      let port = Gopt.getopt "--port" () in
      Gstr.pe (Gstr.unlines ["PID      " ^ Stat.get_pid();
                             "Host     " ^ host;
                             "Port     " ^ port])

    let uninstall () =
      Gstr.pe "Removed jark configs successfully"

    let dispatch cmd arg =
      Gopt.opts := (Glist.list_to_hashtbl arg);
      match cmd with
      | "usage"   -> Gstr.pe usage
      | "install" -> install ()
      | "status"  -> status()
      |  _        -> Gstr.pe usage

end
