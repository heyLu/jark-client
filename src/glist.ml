module Glist =
  struct

    open Unix
    open Printf
    exception Empty_list

    let first xs = 
      (List.hd xs)

    let print_list xs =
      List.iter (fun x -> printf "%s\n" x) xs

    let rec drop n = function
      | _ :: l when n > 0 -> drop (n-1) l
      | l -> l

    let rec last = function
      | [] -> raise Empty_list
      | h :: [] -> h
      | _ :: t -> last t

    let drop_nth l n =
      let rec drop_aux l i =
        match l with
          [] -> []
        | h::t -> if ( i=1 ) 
        then (drop_aux t n)
        else h::( drop_aux t (i-1) )
      in
      drop_aux l n

    let rec zip l1 l2 = match l1,l2 with
    | [],_ -> []
    | _, []-> []
    | (x::xs),(y::ys) -> (x,y) :: (zip xs ys);;

    let list_to_assoc xs =
      let l1 = drop_nth xs 2 in
      let l2 = drop 1 (drop_nth xs 3) in 
      zip l1 l2

    let hkeys h = Hashtbl.fold (fun key _ l -> key :: l) h []

    let hvalues h = Hashtbl.fold (fun _ value l -> value :: l) h []

    let print_hashtbl h =
      List.iter
        (fun key ->
          printf "%s => %s\n" key (Hashtbl.find h key))
        (hkeys h)

    let assoc_to_hashtbl assoc_xs = 
      let h = Hashtbl.create 0 in
      List.iter (fun (k,v) -> Hashtbl.replace h k v) assoc_xs ;
      h

    let list_to_hashtbl xs =
      let assoc_xs = list_to_assoc xs in
      assoc_to_hashtbl assoc_xs

  end 
