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

    val jark_version : string

    val global_opts : Datatypes.config_opts

    val read_config_file : unit -> unit

    val print_config : unit -> unit

  end
