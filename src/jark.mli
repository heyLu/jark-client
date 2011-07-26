module Jark :
  sig

    val eval : string -> unit

    val eval_ns : string -> unit

    val eval_fn : string -> string -> unit

    val eval_nfa : string -> string -> string list -> unit

    val require : string -> unit

    val vm_start : unit -> unit

    val vm_stop : unit -> unit
        
    val vm_connect : unit -> unit

    val package_install : unit -> unit

    val package_versions : unit -> unit

    val package_latest : unit -> unit

    val package_search : string -> unit -> unit

    val swank_start : unit -> unit

    val repo_add : unit -> unit

    val cp_add : string list -> unit

    val ns_load : string -> unit

    val stat_instruments : string list -> unit -> unit

    val stat_vms : unit -> unit

    val install : string -> unit

    val lein : string list -> unit

   end
