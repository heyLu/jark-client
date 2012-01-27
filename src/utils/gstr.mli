module Gstr :
  sig
    
    val split : string -> string -> string list
  
    val lines : string -> string list

    val unlines : string list -> string

    val q : string -> string

    val uq : string -> string

    val stringify : string -> string

    val qq : string -> string

    val pe : string -> unit
       
    val println_unless_empty : string -> unit

    val us : string option -> string

    val notnone : 'a option -> bool

    val maybe_int : string -> int option
        
    val strip : ?chars:string -> string -> string

    val ends_with : string -> string -> bool

    val starts_with : string -> string -> bool

    val join_if_exists : string -> string option list -> string

    val join_nonempty : string -> string list -> string
  end
