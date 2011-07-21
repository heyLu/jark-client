module Gnet =
  struct

    open Unix

    let http_get bin url dest =
      let cmd = bin ^ url ^ " -O " ^ dest in
      Sys.command(cmd);
      ()
end 
