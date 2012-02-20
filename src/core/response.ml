module Response =
  struct

    open Datatypes
    open Gstr

    (* helper functions for response deserialization *)
    let rq x = Str.regexp (Str.quote x)

    let rx x = Str.regexp x

    let remove_rx r x = Str.global_replace (rx r) "" x

    let uq_list x = List.map Gstr.uq x

    let kv_split x = Str.bounded_split (rx ":") x 2

    (* nrepl response idiosyncrasies *)
    let regenerate_newline str = Str.global_replace (rx "\\\\n") "\n" str

    let nilp str = 
      (Gstr.strip (regenerate_newline str)) = "nil"

    (* format strings from response fields *)
    let unescape x =
      let q = rq "\\\"" in
      let db = rq "\\\\" in
      let x = Str.global_replace q "\"" x in
      let x = Str.global_replace db "\\\\" x in
      x

    let fmt_txt x =
      let x = regenerate_newline (Gstr.us x) in
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

    let make_res_string out value res =
      let (>>?) x y = if x then [y] else [] in
      let a = (out   >>? (fmt_txt res.out)) @
              (value >>? (fmt_val res.value "nil"))
      in
      Gstr.join_nonempty "\n" a
     

    (* called by `eval` in the repl
     * NOTE: unlike clojure's repl, we put a newline between out and val
     * even if out is not \n-terminated *)
    let string_of_res ?(out=true) ?(value=true) res = match res.err with
      Some e -> fmt_txt res.err
    | None   -> make_res_string out value res

    (* output err or (both out and value) *)
    let print_res ?(fmt=ResText) res =
      if (Gstr.notnone res.err) then
        print_endline (fmt_txt res.err)
      else
        begin
          Gstr.println_unless_empty (Gstr.strip ~chars:"\n" (fmt_txt res.out));
          Gstr.println_unless_empty (fmt_val res.value ~fmt:fmt "")
        end;
      flush stdout

  end
