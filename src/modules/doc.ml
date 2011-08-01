module Doc =
  struct

    open Glist
    open Gstr
    open Jark
    open Config
    open Gopt

    let usage =
      Gstr.unlines ["usage: jark [options] doc <command> <args>";
                     "Available commands for 'doc' module:\n";
                     "    search     <term>" ; 
                     "    examples   [--show-browser]"]


    let search () =
      ()

    let dispatch cmd arg =
      Gopt.opts := (Glist.list_to_hashtbl arg);
      match cmd with
      | "usage"   -> Gstr.pe usage
      | "search"  -> search()
      |  _        -> Gstr.pe usage
end
