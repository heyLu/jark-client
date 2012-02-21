module Response :
  sig

    val print_res : ?fmt:Ntypes.response_format -> Ntypes.response -> unit

    val string_of_res : ?out:bool -> ?value:bool -> Ntypes.response -> string
  end
