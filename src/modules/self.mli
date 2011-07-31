module Self :
  sig

    val dispatch : string -> string list -> unit

    val usage : string

    val install : unit -> unit

    val status : unit -> unit

  end
