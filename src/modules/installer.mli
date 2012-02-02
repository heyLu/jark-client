module Installer:
  sig
    val install_components : unit -> unit

    val install_standalone : unit -> unit

    val jar : string -> string

    val setup_cljr : unit -> unit

    val deps : string list

  end
