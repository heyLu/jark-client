module Response :
  sig

    val print_res : ?fmt:Datatypes.response_format -> Datatypes.response -> unit

    val string_of_res : ?out:bool -> ?value:bool -> Datatypes.response -> string
  end
