module Gconf :
  sig
    
    val config_path : string ref

    val user_config : (string, string) Hashtbl.t

    val show : unit -> unit

    val load : unit -> unit

    val get : string -> unit -> string

  end
