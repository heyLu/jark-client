module Gconf :
  sig
    
    val user_config : (string, string) Hashtbl.t

    val show : unit -> unit

    val load : unit -> unit

    val get : string -> ?c:string -> unit -> string


  end