module Package :
  sig
    val dispatch : string -> string list -> unit

    val show_usage : unit -> unit

    val install : string list -> unit

    val versions : string list -> unit

    val latest : string list -> unit

    val search : string list -> unit
  end
