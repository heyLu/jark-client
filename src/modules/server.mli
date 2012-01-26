module Server :
  sig
    val dispatch : string -> string list -> unit

    val load : string -> unit

    val install : unit -> unit

    val status : unit -> unit

    val show_usage : unit -> unit

  end

