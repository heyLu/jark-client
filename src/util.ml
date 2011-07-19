(*pp $PP *)

open Printf
open String
open ExtList
open ExtString

(* utility functions *)

let split x y = Str.split (Str.regexp x) y

let lines x = split "\n" x

let unlines xs = concat "\n" xs

let q str = sprintf "\"%s\"" str

let uq str = String.strip ~chars:"\"" str 

let unsome default = function
  | None -> default
  | Some v -> v

let us x = unsome "" x

let notnone x = x != None

let syscall cmd =
  let ic, oc = Unix.open_process cmd in
  let buf = Buffer.create 16 in
  (try
     while true do
       Buffer.add_channel buf ic 1
     done
   with End_of_file -> ());
  let _ = Unix.close_process (ic, oc) in
  (Buffer.contents buf)

let pe s = print_endline s

let stringify s = Str.global_replace (Str.regexp "\"") "\\\"" s

let qq s = stringify (q s)
        
let strip_fake_newline str =
  if String.ends_with str "\\n" then
    String.rchop (String.rchop str)
  else
    str

let print_list xs =
  List.iter (fun x -> printf "%s\n" x) xs

let strip_fake_newline value =
  Str.global_replace (Str.regexp "\\\\n$") " " value

let nilp value = 
  (String.strip (strip_fake_newline (us value))) = "nil"

let regexp_of_glob pat =
  Str.regexp
    (Printf.sprintf "^%s$"
       (String.concat ""
          (List.map
             (function
                | Str.Text s -> Str.quote s
                | Str.Delim "*" -> ".*"
                | Str.Delim "?" -> "."
                | Str.Delim _ -> assert false)
             (Str.full_split (Str.regexp "[*?]") pat))))

(* Now we can build a very basic globber. Only the filename part will
   be used in the glob pattern, so directory wildcards will break in
   this simple example. *)
let glob pat =
  let basedir = Filename.dirname pat in
  let files = Sys.readdir basedir in
  let regexp = regexp_of_glob (Filename.basename pat) in
  List.map
    (Filename.concat basedir)
    (List.filter
       (fun file -> Str.string_match regexp file 0)
       (Array.to_list files))


let get_jars dir = glob (sprintf "%s/*.jar" dir)
  
