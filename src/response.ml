module Response =
  struct

    open Datatypes
    open Gstr

    (* nrepl response idiosyncrasies *)
    let strip_fake_newline str =
      Str.global_replace (Str.regexp "\\\\n$") " " str

    let nilp str = 
      (Gstr.strip (strip_fake_newline str)) = "nil"

    (* format strings from response fields *)
    let fmt x = strip_fake_newline (Gstr.us x)

    (* res.value needs "nil" to be special-cased *)
    let fmt_val x nilv =
      let v = fmt x in
      if (nilp v) then nilv else v

    (* output err or (both out and value) *)
    let output_res res =
      if (Gstr.notnone res.err) then 
        print_endline (fmt res.err)
      else
        begin
          Gstr.println_unless_empty (fmt res.out);
          Gstr.println_unless_empty (fmt_val res.value "")
        end;
      flush stdout

    (* first non-null in err, out, value *)
    let string_of_res res = match (res.err, res.out, res.value) with
      (Some e, _, _)       -> fmt res.err
    | (None, Some o, _)    -> fmt res.out
    | (None, None, Some v) -> fmt_val res.value "nil"
    | (None, None, None)   -> "nil"

  end
