module Jark :
  sig

    val eval : string -> ?out:bool -> ?value:bool -> unit -> string

    val nfa : string -> ?f:string -> ?a:string list ->
      ?fmt:Ntypes.response_format -> unit -> unit

    val pfa : string -> ?f:string -> ?a:string list -> unit -> unit

    val require : string -> string

    val dispatch : string list -> unit

    val value_of : string -> string

   end
