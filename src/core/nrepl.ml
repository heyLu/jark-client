(*pp $PP *)


(* The Nrepl module is written by Martin Demello *) 
(* Ref: https://github.com/martindemello/ocaml-nrepl-client.git *)

module Nrepl =
  struct
    
    open Printf
    open Datatypes
    open Gstr  

    let debug = true

    let debugging x =
      if debug then print_endline x;
      x

    let new_response = {
      id     = None;
      out    = None;
      err    = None;
      value  = None;
      status = None;
    }

    let bad_response =
      {new_response with err = Some("Bad response from server")}

    let empty_response = 
      {new_response with err = Some("Empty response from server")}

    let update_response res (x, y) =
      let y = Some (Gstr.uq y) in
      match (Gstr.uq x) with
      | "id"     -> {res with id = y};
      | "out"    -> {res with out = y};
      | "err"    -> {res with err = y};
      | "value"  -> {res with value = y};
      | "status" -> {res with status = y};
      | _        -> res (* TODO: raise malformed response *)

    type state = NewPacket | Receiving of int | Done

    let readlines socket =
      let input = Unix.in_channel_of_descr socket in
      let getline () = debugging (try input_line input with End_of_file -> "") in
      let value = ref None in
      let out = ref [] in
      let err = ref None in
      let rec get s res =
        match s with
        | NewPacket ->
            let line = getline () in
            begin
              match (line, Gstr.maybe_int line) with
              | "", _     -> empty_response
              | _, None   -> bad_response
              | _, Some i ->  get (Receiving i) new_response
            end
        | Done ->
            let out = match !out with
            | [] -> None
            | _  -> Some (String.concat "" (List.map Gstr.us (List.rev !out)))
            in
            {res with value = !value; out = out; err = !err}
        | Receiving 0 ->
            if Gstr.notnone res.err then err := res.err;
            if Gstr.notnone res.out then out := res.out :: !out;
            if Gstr.notnone res.value then value := res.value;
            get NewPacket res
        | Receiving n ->
            let k = getline () in
            let v = getline () in
            let res = update_response res (k, v) in
            match res.status with
            | Some "done"  -> get Done res
            | _            -> get (Receiving (n - 1)) res
            in
            get NewPacket new_response

    let write_all socket s =
      Unix.send socket s 0 (String.length s) []

    let nrepl_message_packet msg =
      ["2"; Gstr.q "id"; Gstr.q msg.mid; Gstr.q "code"; Gstr.q msg.code]

    let send_msg env msg =
      let socket = Unix.socket Unix.PF_INET Unix.SOCK_STREAM 0 in
      let hostinfo = Unix.gethostbyname env.host in
      let server_address = hostinfo.Unix.h_addr_list.(0) in
      let _ = Unix.connect socket (Unix.ADDR_INET (server_address, env.port)) in
      let msg = Gstr.unlines (nrepl_message_packet msg) in
      let _ = write_all socket msg in
      let res = readlines socket in
      Unix.close socket;
      res
  end
