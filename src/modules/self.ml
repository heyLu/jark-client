module Self =
  struct

    open Glist
    open Gstr
    open Gfile
    open Jark
    open Config
    module C = Config
    open Stat

    let usage =
      Gstr.unlines ["usage: jark [options] self <command> <args>";
                     "Available commands for 'self' module:\n";
                     "    install     [--no-standalone] [--force]" ; 
                     "    uninstall ";
                     "    status      VM connection status"]


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
      let host = C.getopt "--host" in
      let port = C.getopt "--port" in
      Gstr.pe (Gstr.unlines ["PID      " ^ Stat.get_pid();
                             "Host     " ^ host;
                             "Port     " ^ port])

    let dispatch cmd arg =
      Config.opts := (Glist.list_to_hashtbl arg);
      match cmd with
      | "usage"   -> Gstr.pe usage
      | "install" -> install ()
      | "status"  -> status()
      |  _        -> Gstr.pe usage

end
