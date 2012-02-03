module Installer:
  sig
    val install_components : unit -> unit

    val install_standalone : unit -> unit

    val conf : Datatypes.install_opts

    val jar : string -> string

    val setup_cljr : unit -> unit

    val deps : string list

    val read_config : unit -> unit

    val cljr_lib : unit -> string

  end
