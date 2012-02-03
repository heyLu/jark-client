module Installer:
  sig
    val install_standalone : unit -> unit

    val conf : Datatypes.install_opts

    val standalone_jar : string

    val standalone_path : string

    val setup_cljr : unit -> unit

    val set_install_opt : string -> string -> unit

    val read_config : unit -> unit

    val cljr_lib : unit -> string

  end
