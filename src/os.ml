open Unix

module Os =
  struct

    let syscall cmd =
      let ic, oc = Unix.open_process cmd in
      let buf = Buffer.create 16 in
      (try
        while true do
          Buffer.add_channel buf ic 1
        done
      with End_of_file -> ());
      let _ = Unix.close_process (ic, oc) in
      (Buffer.contents buf)

    let is_windows () = (Sys.os_type = "Win32")
end 
