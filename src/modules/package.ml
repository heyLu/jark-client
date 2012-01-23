module Package =
  struct

    open Datatypes
    open Glist
    open Gstr
    open Jark
    open Config
    open Plugin

    let registry = Plugin.create ()
    let register_fn = Plugin.register_fn registry
    let alias_fn = Plugin.alias_fn registry

    let show_usage args = Plugin.show_usage registry "package"

    let install args =
      Jark.nfa "jark.package" ~f:"install" ~a:args ()

    let versions args =
      Jark.nfa "jark.package" ~f:"versions" ~a:args ()

    let latest args =
      Jark.nfa "jark.package" ~f:"latest-version" ~a:args ()

    let search args =
      Jark.nfa "jark.package" ~f:"search" ~a:args ~fmt:ResHash ()

    let deps args =
      Jark.nfa "jark.package" ~f:"dependencies" ~a:args ()

    let uninstall args =
      Jark.nfa "jark.package" ~f:"uninstall" ~a:args ()

    let pkg_list args =
      Jark.nfa "jark.package" ~f:"list" ~fmt:ResHash ()

    let _ =
      register_fn "install" install [
        "-p|--package <package> [-v|--version <version>]" ;
        "Install the relevant version of package from clojars"] ;

      register_fn "uninstall" uninstall [
        "<package>";
        "Uninstall the package"];

      register_fn "versions" versions [
        "-p|--package <package>" ;
        "List the versions of package installed"];

      register_fn "deps" deps [
        "<package> <version>]";
        "Print the library dependencies of package\n"];

      register_fn "search" search [
        "-p|--package <package>";
        "Search clojars for package\n"];

      register_fn "latest" latest [
        "-p|--package <package>" ;
        "Print the latest version of the package" ];

      register_fn "list" pkg_list ["List all packages installed\n"];

      alias_fn "list" ["ls"; "installed"]

    let dispatch cmd arg =
      Plugin.dispatch registry cmd arg

end
