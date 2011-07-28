module Jark :
  sig

    val eval : string -> unit -> string

    val nrepl_send_np : Datatypes.env -> Datatypes.nrepl_message -> unit -> string

    val nfa : string -> ?f:string -> ?a:string list -> unit -> unit

    val require : string -> string

    val vm_start : unit -> unit

    val vm_stop : unit -> unit

    val vm_connect : unit -> unit

    val vm_status : unit -> unit

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
