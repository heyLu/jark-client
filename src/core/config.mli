module Config :
  sig
    val platform : Datatypes.platform_config

    val set_env : Datatypes.env -> unit

    val get_env : unit -> Datatypes.env

    val cljr : unit -> string

    val cljr_lib : unit -> string

    val server_cp : unit -> string

    val server_jar : string -> string

    val jark_version : string

    val global_opts : Datatypes.config_opts

    val read_config_file : (string -> string -> unit) -> unit

    val read_config : unit -> unit

    val print_config : unit -> unit

  end
