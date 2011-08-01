module Gopt :
  sig

    val opts : (string, string) Hashtbl.t ref

    val default_opts : (string, string list) Hashtbl.t ref

    val getopt : string -> unit -> string

        
  end
