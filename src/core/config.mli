module Config :
  sig

    val set_env : Datatypes.env -> unit

    val get_env : unit -> Datatypes.env

    val cp_boot : unit -> string

    val cljr : string

    val cljr_lib : string

    val setup_cljr : unit -> unit

    val standalone : bool

    val install_components : unit -> unit

    val install_standalone : unit -> unit

    val jar : string -> string

    val remove_config : unit -> unit

    val jark_version : string

    val default_opts : Datatypes.config_opts

  end
