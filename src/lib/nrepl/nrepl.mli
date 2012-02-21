module Nrepl :
  sig
    val send_msg : Ntypes.env -> Ntypes.nrepl_message -> Ntypes.response
  end
