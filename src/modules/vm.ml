module Vm =
  struct

    open Datatypes
    open Printf
    open Gstr
    open Jark
    open Config
    module C = Config
    open Options
    open Jvm
    open Plugin

    let registry = Plugin.create ()
    let register_fn = Plugin.register_fn registry
    let alias_fn = Plugin.alias_fn registry

    let show_usage args = Plugin.show_usage registry "vm"

    let _ =
      register_fn "start" Jvm.start [
        "[-p|--port=<9000>] [-j|--jvm-opts=<opts>] [--log=<path>]" ;
        "Start a local Jark server. Takes optional JVM options as a \" delimited string"];

      register_fn "stop" Jvm.stop [
        "[-n|--name=<vm-name>]";
        "Shuts down the current instance of the JVM"]

    let dispatch cmd args =
      match cmd with
      | "start" -> Jvm.start args
      | "stop"  -> Jvm.stop args
      | _       -> Jark.nfa "jark.vm" ~f:cmd ~a:args ()

end
