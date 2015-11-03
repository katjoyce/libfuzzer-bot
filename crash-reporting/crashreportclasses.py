"""Crash report class module.

This module defines data structures in which to store crash information.
"""


class CrashReport(object):
    """A structure in which to store information about a single crash.

    Attributes:
        input_file:  A string representing the input file name that caused this
                     particular crash.
        commands:     The command, as a list, that was run to cause the crash.
        signal:      A string representing the signal that was generated by the
                     crash e.g SIGSEGV
        stack_trace: The stack trace after the crash as a StackTrace object.
        error_msg:   The error message string that was output when the crash
                     occurred.
    """
    def __init__(self, input_file, commands, signal, stack_trace, error_msg):
        self.input_file = input_file
        self.commands = commands
        self.signal = signal
        self.stack_trace = stack_trace
        self.error_msg = error_msg

    def __str__(self):
        return ("Input file: {0.input_file!s}\n"
                "Command: {1!s}\n"
                "Signal: {0.signal!s}\n"
                "Stack trace:\n{0.stack_trace!s}\n"
                "Error message:\n"
                "{0.error_msg!s}").format(self, " ".join(self.commands))


class StackTrace(object):
    """
    Attributes:
        frames: A list of StackFrame objects that make up this stack
                      trace.
    """
    def __init__(self, frames):
        self.frames = frames

    def __str__(self):
        return "\n".join([str(frame) for frame in self.frames])

    def depth(self):
        """Returns the number of stack frames in the stack trace."""
        return len(self.frames)


class StackFrame(object):
    """A structure in which to store information about a stack frame.

    Attributes:
        position: The position of this stack frame in
                  the outer stack trace.
        function: The function name that this stack frame refers to.
        filename: The filename that this stack frame refers to.
        line_num: The line number that this stack frame refers to.
    """
    def __init__(self, position, function, filename, line_num):
        self.position = position
        self.function = function
        self.filename = filename
        self.line_num = line_num

    def __str__(self):
        return "#{!s} {!s}:{!s}: {!s}()".format(self.position, self.filename,
                                                self.line_num, self.function)
