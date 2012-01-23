module Doc =
  struct

    open Glist
    open Gstr
    open Jark
    open Config
    open Plugin

    let registry = Plugin.create ()
    let register_fn = Plugin.register_fn registry
    let alias_fn = Plugin.alias_fn registry

    let show_usage args = Plugin.show_usage registry "doc"

    let search args = Gstr.pe "Not implemented yet"

    let examples args = Gstr.pe "Not implemented yet"

    let _ =
      register_fn "search" search ["<term>"];

      register_fn "examples" examples ["[--show-browser]"]

    let dispatch cmd arg =
      Plugin.dispatch registry cmd arg
end
