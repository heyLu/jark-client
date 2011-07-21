module Gstr =
  struct

    exception Invalid_string

    open Printf
    open Unix
    open String


    let strip ?(chars=" \t\r\n") s =
      let p = ref 0 in
      let l = length s in
      while !p < l && contains chars (unsafe_get s !p) do
	incr p;
      done;
      let p = !p in
      let l = ref (l - 1) in
      while !l >= p && contains chars (unsafe_get s !l) do
	decr l;
      done;
      sub s p (!l - p + 1)

    let starts_with str p =
      let len = length p in
      if length str < len then 
	false
      else
	sub str 0 len = p

    let ends_with s e =
      let el = length e in
      let sl = length s in
      if sl < el then
	false
      else
	sub s (sl-el) el = e

    let rchop s =
      if s = "" then "" else sub s 0 (length s - 1)

  
    let split x y = Str.split (Str.regexp x) y

    let lines x = split "\n" x
        
    let unlines xs = concat "\n" xs
    
    let q str = sprintf "\"%s\"" str
        
    let uq str = strip ~chars:"\"" str 

    let stringify s = Str.global_replace (Str.regexp "\"") "\\\"" s

    let qq s = stringify (q s)

    let unsome default = function
      | None -> default
      | Some v -> v

    let us x = unsome "" x

    let notnone x = x != None
        
    let strip_fake_newline str =
      if ends_with str "\\n" then
        rchop (rchop str)
      else
        str

    let strip_fake_newline str =
      Str.global_replace (Str.regexp "\\\\n$") " " str

    let nilp str = 
      (strip (strip_fake_newline (us str))) = "nil"

    let pe str = print_endline str

    let to_int s =
      try
	int_of_string s
      with
	_ -> raise Invalid_string

end 
