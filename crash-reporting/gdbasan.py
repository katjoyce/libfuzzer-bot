"""Module providing functionality required when running gdb on an executable
compiled with ASan."""

import os
import re

_GDB_DISCARD_RE = [
    "^Continuing.",
    "\[Inferior [0-1] \(process [0-9]+\) exited with code [0-9]+\]"
    ]
_SIGASAN = "ASAN"


#TODO(katjoyce): make this more future proof, eg if symbolizer version changes.
def set_asan_vars():
    os.environ["ASAN_SYMBOLIZER_PATH"] = "/usr/bin/llvm-symbolizer-3.4"


def detect_asan(break_output):
    if re.search("Breakpoint [0-9] at ", break_output) is not None:
        return True
    return False


def parse_asan_error(err_msg):
    """
    Returns:
        A tuple (signal, err_msg):
            signal: The signal received when the crash happened.
            err_msg: The error message corresponding to the crash.
    """
    if err_msg == "The program is not being run.\n":
        return None, None
    #TODO(katjoyce): Deal with C++ behaviour & gdb output.
    #TODO(katjoyce): Possible extension which may be useful in future: be able
    #to return specific Asan error type eg heap overflow, stack overflow etc.
    for regex in _GDB_DISCARD_RE:
        err_msg = re.sub(regex, "", err_msg).strip("\n")
    return _SIGASAN, err_msg
