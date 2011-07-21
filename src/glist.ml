module Glist =
  struct

    open Unix
    open Printf

    let first = List.hd

    let print_list xs =
      List.iter (fun x -> printf "%s\n" x) xs

    let list_to_hashtbl xs =
      xs

    let rec drop n = function
      | _ :: l when n > 0 -> drop (n-1) l
      | l -> l

end 
