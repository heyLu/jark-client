module Config :
  sig
    
    val set_env : unit -> Datatypes.env
    
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

    val java_tools_path : unit -> string

    val jark_version : string

    val default_opts :  (string * string list) list

  end
