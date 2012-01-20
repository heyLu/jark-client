type env = {
  ns          : string;
  debug       : bool;
  host        : string;
  port        : int;
}

type nrepl_message = {
  mid: string;
  code: string;
}

type response = {
  id     : string option;
  out    : string option;
  err    : string option;
  value  : string option;
  status : string option;
}

(* platform-specific string constants *)
type platform_config = {
  cljr: string;
  config_dir: string;
  jark_config_dir: string;
  config_file: string;
  wget_bin: string;
}

type response_format = ResText | ResHash | ResList
