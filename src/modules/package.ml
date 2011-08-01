module Package =
  struct

    open Glist
    open Gstr
    open Jark
    open Config
    open Gopt

    let usage = 
      Gstr.unlines ["usage: jark [options] package <command> <args>";
                     "Available commands for 'package' module:\n";
                     "    install    -p|--package <package> [-v|--version <version>]" ;
                     "               Install the relevant version of package from clojars\n" ;
                     "    uninstall  -p|--package <package>" ;
                     "               Uninstall the package\n" ;
                     "    versions   -p|--package <package>" ;
                     "               List the versions of package installed\n" ;
                     "    deps       -p|--package <package> [-v|--version <version>]" ;
                     "               Print the library dependencies of package\n" ;
                     "    search     -p|--package <package>" ;
                     "               Search clojars for package\n" ;
                     "    list       List all packages installed\n" ;
                     "    latest     -p|--package <package>" ;
                     "               Print the latest version of the package" ]


    let install () =
      let package = Gopt.getopt "--package" () in 
      Jark.nfa "jark.package" ~f:"install" ~a:[package] ()

    let versions () =
      let package = Gopt.getopt "--package" () in 
      Jark.nfa "jark.package" ~f:"versions" ~a:[package] ()

    let latest () =
      let package = Gopt.getopt "--package" () in 
      Jark.nfa "jark.package" ~f:"latest-version" ~a:[package] ()

    let search term () =
      Jark.nfa "jark.package" ~f:"search" ~a:[term] ()

    let dispatch cmd arg =
      Gopt.opts := (Glist.list_to_hashtbl arg);
      match cmd with
      | "usage"     -> Gstr.pe usage
      | "install"   -> install() 
      | "versions"  -> versions()
      | "deps"      -> Gstr.pe "deps"
      | "installed" -> Jark.nfa "jark.package" ~f:"list" ()
      | "list"      -> Jark.nfa "jark.package" ~f:"list" ()
      | "latest"    -> latest()
      | "search"    -> search (List.hd arg) ()
      |  _          -> Gstr.pe usage

end
