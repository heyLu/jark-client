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
    mutable cljr: string;
    mutable config_file: string;
    mutable wget_bin: string;
  }

type response_format = ResText | ResHash | ResList

type output_opts = {
    mutable json            : bool;
}

(* server options *)

type server_opts = {
    mutable jvm_opts        : string;
    mutable log_file        : string;
    mutable install_root    : string;
    mutable http_client     : string;
    mutable clojure_version : string;
    mutable server_version  : string
} 

type cmd_opts = {
  env : env;
  show_version: bool;
  show_config: bool;
  eval : bool ;
  server_opts : server_opts;
  args : string list
}
