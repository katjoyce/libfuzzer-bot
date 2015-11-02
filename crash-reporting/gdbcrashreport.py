"""GDB implementation to create an individual crash report."""

import re
import subprocess
import sys

from crashreportclasses import CrashReport
from crashreportclasses import StackTrace
from crashreportclasses import StackFrame

_DEBUGGER = "gdb"
_DEBUGGER_ARGS = ["--args"]
_DEBUGGER_INPUT = "run\nbt\nquit\n"

_GDB_DISCARD_RE = re.compile("^Starting program:\s+.*?\n")
_GDB_ERROR_RE = re.compile("Program received signal (?P<signal>SIG[A-Z]+)")
_GDB_STRIPPED_RE = re.compile("WARNING: no debugging symbols found")
_GDB_STACK_FRAME_RE = re.compile("#(?P<no>\d+)\s+0x[0-9a-z]+\s+"
                                 "in\s+(?P<func>\S+)\s*\([^)]*\)\s+"
                                 "at\s+(?P<fname>[^:]+):(?P<lnum>\d+)")


def _parse_stack_trace(trace_str):
    stack_tr = []
    frame_strings = _GDB_STACK_FRAME_RE.findall(trace_str)
    for frame in frame_strings:
        stack_tr.append(StackFrame(*frame))
    return StackTrace(stack_tr)


def _parse_error(err_msg):
    err_msg = _GDB_DISCARD_RE.sub("", err_msg).strip("\n")
    match = _GDB_ERROR_RE.search(err_msg)
    if match is None:
        return "", err_msg
    return match.group("signal"), err_msg


def _check_for_stripped_binary(preamble):
    match = _GDB_STRIPPED_RE.search(preamble)
    if match is not None:
        raise Exception("Error: Stripped binary.  "
                        "No useful crash information available.\n")


def _check_for_debugger():
    try:
        subprocess.check_output([_DEBUGGER, "-v"])
    except OSError:
        print >> sys.stderr, ("Error: {0!s} not found.  Please make sure you "
                              "have {0!s} installed.").format(_DEBUGGER)
        sys.exit(1)


def _extract_crash_info(cmds):
    # TODO(katjoyce): What if debugger stops and waits for user input of some
    #       sort?  Timeout required.
    _check_for_debugger()
    debug_proc = subprocess.Popen([_DEBUGGER] + _DEBUGGER_ARGS + cmds,
                                  stdin=subprocess.PIPE,
                                  stdout=subprocess.PIPE,
                                  stderr=subprocess.PIPE)
    return debug_proc.communicate(input=_DEBUGGER_INPUT)[0]


def create_crash_report(input_name, cmds):
    """Creates a crash report for when an executable is run on a specific
    input.

    Args:
        input_name: The name of the input file on which the executable is being
                    run.
        cmds: The command to be run, as a list.
    Returns:
        A populated CrashReport object.
    """
    crash_data = _extract_crash_info(cmds)
    gdb_out_sections = crash_data.split("(gdb) ")
    try:
        _check_for_stripped_binary(gdb_out_sections[0])
    except Exception as e:
        sys.stderr.write(str(e))
        sys.exit(1)
    sig, err = _parse_error(gdb_out_sections[1])
    stack_tr = _parse_stack_trace(gdb_out_sections[2])
    return CrashReport(input_name, cmds, sig, err, stack_tr)
