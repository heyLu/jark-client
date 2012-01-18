module Response :
  sig

    val print_res : ?fmt:Datatypes.response_format -> Datatypes.response -> unit

    val string_of_res : Datatypes.response -> string
  end
