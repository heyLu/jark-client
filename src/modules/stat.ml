module Stat =
  struct

    open Printf
    open Glist
    open Gstr
    open Jark
    open Config
    open Gopt

    let usage = 
      Gstr.unlines ["usage: jark stat <command> <args>";
                     "Available commands for 'stat' module:\n";
                     "    instruments    [prefix]" ;
                     "                   List all available instruments. Optionally takes a regex\n" ;
                     "    instrument     <instrument-name>" ;
                     "                   Print the value for the given instrument name\n" ;
                     "    mem            Print the memory usage of the JVM\n" ;
                     "    vms            --remote-host <host>" ;
                     "                   List the vms running on remote host\n"]

    let show_usage () = Gstr.pe usage

    let get_pid () =
      Gstr.strip (Jark.eval (sprintf "(jark.ns/dispatch \"jark.vm\" \"get-pid\")") ())

    let instrument instrument_name () =
      Jark.nfa "recon.core" ~f:"instrument-value" ~a:["localhost"; get_pid() ; instrument_name] ()

    let instruments xs () =
      try
        instrument (List.hd xs) ()
      with Failure("hd") ->
        Jark.nfa "recon.core" ~f:"instrument-names" ~a:["localhost"; get_pid()] ()

    let vms () =
      let remote_host = Gopt.getopt "--remote-host" () in 
      Jark.nfa "recon.core" ~f:"vms" ~a:[remote_host] ()

    let dispatch cmd arg =
      Gopt.opts := (Glist.list_to_hashtbl arg);
      match cmd with
      | "instruments"   -> instruments arg ()
      | "instrument"    -> instruments arg ()
      | "vms"           -> vms () 
      | "mem"           -> Jark.nfa "jark.vm" ~f:"stats" ()
      |  _              -> Gstr.pe usage

end
