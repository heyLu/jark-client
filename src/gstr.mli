module Gstr :
  sig
    
    val split : string -> string -> string list
  
    val lines : string -> string list

    val unlines : string list -> string

    val q : string -> string

    val uq : string -> string

    val stringify : string -> string

    val qq : string -> string

    val strip_fake_newline : string -> string

    val nilp : string option -> bool

    val pe : string -> unit
       
    val us : string option -> string

    val notnone : 'a option -> bool

    val to_int : string -> int
        
    val strip : ?chars:string -> string -> string

    val ends_with : string -> string -> bool

    val starts_with : string -> string -> bool
  end
