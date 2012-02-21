
(* platform-specific string constants *)
type platform_config = {
    mutable cljr: string;
    mutable config_path: string;
    mutable wget_bin: string;
  }

(* server options *)

type server_opts = {
    mutable jvm_opts        : string;
    mutable log_file        : string;
    mutable install_root    : string;
    mutable http_client     : string;
    mutable clojure_version : string;
    mutable server_version  : string;
    mutable classpath       : string;
    mutable config_file     : string;
    mutable output_format   : string
} 

type cmd_opts = {
  env          : Ntypes.env;
  show_version : bool;
  show_config  : bool;
  eval         : bool ;
  server_opts  : server_opts;
  args         : string list
}
