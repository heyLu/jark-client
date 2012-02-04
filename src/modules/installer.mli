module Installer:
  sig
    val install_server : string -> unit

    val conf : Datatypes.install_opts

    val read_config : unit -> unit

  end
