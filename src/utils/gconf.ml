(*pp $PP *)

module Gconf =
  struct

    open Printf
    open Datatypes
    open Gsys
    open Gnet
    open Glist
    open Gstr
    open Gfile

    let config_path = ref ""
        
    let user_config = Hashtbl.create 0

    let line_stream_of_channel channel =
      Stream.from
        (fun _ -> try Some (input_line channel) with End_of_file -> None)
 
    let format s = 
      let comments = Str.regexp "#.*" in
      let leading_white = Str.regexp "^[ \t]+" in
      let trailing_white = Str.regexp "[ \t]+$" in
      let equals_delim = Str.regexp "[ \t]*=[ \t]*" in
      let s = Str.replace_first comments "" s in
      let s = Str.replace_first leading_white "" s in
      let s = Str.replace_first trailing_white "" s in
      if String.length s > 0 then
        let [k ; v] = Str.bounded_split_delim equals_delim s 2 in
        Hashtbl.replace user_config k v

    let show () =
      Glist.print_hashtbl user_config
          
    let load () =
      if (Gfile.exists !config_path) then begin
        let config = (open_in !config_path) in 
        Stream.iter format  (line_stream_of_channel config);
        close_in config
      end
      else
        ()

    let get key () =
      if (Hashtbl.mem user_config key) then
        Hashtbl.find user_config key
      else
        "nil"

end

      
