module Glist :
  sig

    val print_list : string list -> unit

    val first : 'a list -> 'a

    val drop : int -> 'a list -> 'a list

    val last : 'a list -> 'a

    (* hashtable routines *)

    val assoc_to_hashtbl : ('a * 'b) list -> ('a, 'b) Hashtbl.t

    val print_hashtbl : (string, string) Hashtbl.t -> unit

    val hkeys : ('a, 'b) Hashtbl.t -> 'a list

    val hvalues : ('a, 'b) Hashtbl.t -> 'b list
        
    val list_to_hashtbl : 'a list -> ('a, 'a) Hashtbl.t

  end
