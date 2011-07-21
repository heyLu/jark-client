module Gstr =
  struct

    open Printf
    open Unix
    open String
    open ExtList
    open ExtString
  
    let split x y = Str.split (Str.regexp x) y

    let lines x = split "\n" x
        
    let unlines xs = concat "\n" xs
    
    let q str = sprintf "\"%s\"" str
        
    let uq str = String.strip ~chars:"\"" str 

    let stringify s = Str.global_replace (Str.regexp "\"") "\\\"" s

    let qq s = stringify (q s)

    let unsome default = function
      | None -> default
      | Some v -> v

    let us x = unsome "" x

    let notnone x = x != None
        
    let strip_fake_newline str =
      if String.ends_with str "\\n" then
        String.rchop (String.rchop str)
      else
        str

    let strip_fake_newline str =
      Str.global_replace (Str.regexp "\\\\n$") " " str

    let nilp str = 
      (String.strip (strip_fake_newline (us str))) = "nil"

    let pe str = print_endline str

end 
