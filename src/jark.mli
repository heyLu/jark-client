module Jark :
  sig

    val eval : string -> unit -> string

    val nrepl_send_np : Datatypes.env -> Datatypes.nrepl_message -> unit -> string

    val nfa : string -> ?f:string -> ?a:string list -> unit -> unit

    val require : string -> string

   end
