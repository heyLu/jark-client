module Config :
  sig
    val platform : Optiontypes.platform_config

    val set_env : Ntypes.env -> unit

    val get_env : unit -> Ntypes.env

    val get_server_opts : unit -> Optiontypes.server_opts

    val set_server_opts : Optiontypes.server_opts -> unit

    val cljr_lib : string -> unit -> string

    val server_cp : string -> string -> string -> unit -> bool

    val server_jar : string -> string -> string -> unit -> string

    val jark_version : string

    val read_config_file : (string -> string -> unit) -> string -> unit -> unit

    val read_config : unit -> unit

    val print_config : unit -> unit

    val classpath : unit -> string

    val check_valid_clojure_version : string -> unit -> bool
  end
