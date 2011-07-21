module Glist =
  struct

    open Unix

    let print_list xs =
      List.iter (fun x -> printf "%s\n" x) xs

    let list_to_hashtbl xs =
      xs
        
end 
