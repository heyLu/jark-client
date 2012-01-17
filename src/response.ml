module Response =
  struct

    open Datatypes
    open Gstr

    type response_output = Err of string | Out of string | Val of string

    (* helper functions for response deserialization *)
    let rq x = Str.regexp (Str.quote x)

    let rx x = Str.regexp x

    let remove_rx r x = Str.global_replace (rx r) "" x

    let uq_list x = List.map Gstr.uq x

    let kv_split x = Str.bounded_split (rx ":") x 2

    (* nrepl response idiosyncrasies *)
    let strip_fake_newline str = remove_rx "\\\\n$" str

    let nilp str = 
      (Gstr.strip (strip_fake_newline str)) = "nil"

    (* format strings from response fields *)
    let unescape x =
      let q = rq "\\\"" in
      let db = rq "\\\\" in
      let x = Str.global_replace q "\"" x in
      let x = Str.global_replace db "\\\\" x in
      x

    let fmt_txt x =
      let x = strip_fake_newline (Gstr.us x) in
      unescape x

    (* handle stringified file lists and hashes in response *)
    let deserialize_common x =
      let x = unescape x in
      let x = Gstr.strip x in
      let x = Gstr.uq x in
      let fs = rq "\\/" in
      let x = Str.global_replace fs "/" x in
      x

    let deserialize_list x =
      let x = deserialize_common x in
      let x = Gstr.strip ~chars:"\\[]" x in
      let xs = Gstr.split "," x in
      Gstr.unlines (List.map Gstr.uq xs)

    let deserialize_hash x =
      let x = deserialize_common x in
      let x = Gstr.strip ~chars:"\\{}" x in
      let xs = Gstr.split "," x in
      let kvs = List.map kv_split xs in
      let kvs = List.map uq_list kvs in
      Gstr.unlines (List.map (String.concat " : ") kvs)

    (* res.value needs "nil" and datastructures to be special-cased *)
    let fmt_val x ?(fmt=ResText) nilv =
      let v = fmt_txt x in
      if (nilp v) then nilv
      else match fmt with
        ResText -> v
      | ResList -> deserialize_list v
      | ResHash -> deserialize_hash v

    (* first non-null in err, out, value *)
    (* TODO: surely we should handle both out and val everywhere *)
    let output_of_res res = match (res.err, res.out, res.value) with
      (Some e, _, _)       -> Err (fmt_txt res.err)
    | (None, Some o, _)    -> Out (fmt_txt res.out)
    | (None, None, Some v) -> Val (fmt_val res.value "nil")
    | (None, None, None)   -> Val ("nil")

    let string_of_res res = match output_of_res res with
    Err x | Out x | Val x -> x

    (* output err or (both out and value) *)
    let print_res ?(fmt=ResText) res =
      if (Gstr.notnone res.err) then 
        print_endline (fmt_txt res.err)
      else
        begin
          Gstr.println_unless_empty (fmt_txt res.out);
          Gstr.println_unless_empty (fmt_val res.value ~fmt:fmt "")
        end;
      flush stdout

  end
