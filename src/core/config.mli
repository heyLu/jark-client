module Config :
  sig
    val platform : Datatypes.platform_config

    val set_env : Datatypes.env -> unit

    val get_env : unit -> Datatypes.env

    val get_server_opts : unit -> Datatypes.server_opts

    val set_server_opts : Datatypes.server_opts -> unit

    val cljr_lib : string -> unit -> string

    val server_cp : string -> string -> string -> unit -> bool

    val server_jar : string -> string -> string -> unit -> string

    val jark_version : string

    val read_config_file : (string -> string -> unit) -> unit -> unit

    val read_config : unit -> unit

    val print_config : unit -> unit

  end
