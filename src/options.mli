module Options :
  sig
    exception BadOptions of string

    type opt =
        Set_on of bool ref
      | Set_off of bool ref
      | Set_string of string ref
      | Set_int of int ref
      | Unknown
          
    type opt_spec = (string * opt * string) list

    val parse_argv : opt_spec -> string list

    val parse : string list -> opt_spec -> string list

  end
