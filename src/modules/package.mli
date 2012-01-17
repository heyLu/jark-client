module Package :
  sig

    val dispatch : string -> string list -> unit

    val usage : string

    val show_usage : unit -> unit

    val install : unit -> unit

    val versions : unit -> unit

    val latest : unit -> unit

    val search : string -> unit -> unit


  end
