module Glist :
  sig
    val print_list : string list -> unit

    val first : 'a list -> 'a

    val drop : int -> 'a list -> 'a list
  end
