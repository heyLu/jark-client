module Config :
  sig
    val platform : Datatypes.platform_config

    val set_env : Datatypes.env -> unit

    val get_env : unit -> Datatypes.env

    val cljr : string

    val cljr_lib : string

    val standalone : bool

    val jark_version : string

    val global_opts : Datatypes.config_opts

    val read_config_file : unit -> unit

    val print_config : unit -> unit

  end
