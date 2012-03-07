type env = {
    ns          : string;
    debug       : bool;
    mutable host        : string;
    mutable port        : int;
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

type response_format = ResText | ResHash | ResList
