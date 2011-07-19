module Jark :
  sig

    val eval_cmd : string -> string -> unit

    val eval : string -> unit

    val vm_start : string -> unit

    val vm_connect : string -> int -> unit

    val cp_add : string list -> unit

    val ns_load : string -> unit

    val install : string -> unit

    val eval_cmd_args : string -> string -> string list -> unit

    val eval_ns : string -> unit

    val eval_fn : string -> string -> unit

    val eval_nfa : string -> string -> string list -> unit

   end
