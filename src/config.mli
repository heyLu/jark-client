module Config :
  sig
    
    val set_env : ?host:string -> ?port:int -> unit -> Datatypes.env
    
    val get_env : unit -> Datatypes.env

    val cp_boot : unit -> string

    val getc : unit -> unit -> 'a list

    val cljr : string

    val cljr_lib : string

    val setup_cljr : unit -> unit

    val standalone : bool

    val install_components : unit -> unit
        
    val install_standalone : unit -> unit

    val jar_standalone : string

  end
