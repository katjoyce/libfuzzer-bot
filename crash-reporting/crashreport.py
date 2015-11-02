#! /usr/bin/python
"""Crash report generation.

Generates structured crash information from inputs that cause an executable to
crash.

Usage: /path/to/crash-report.py <crash-inputs-dir> /path/to/executable
         [...executable's cmdline options/arguments...]

Put @@ in the executable's command line as a placeholder for where an input
file should be inserted.  The script will run the executable on each input file
in <crash-inputs-dir> in order to generate a crash report for every file in
<crash-inputs-dir>.

"""

import sys
import os

from gdbcrashreport import create_crash_report

NON_CRASHES = ["README.txt"]
PLACEHOLDER = "@@"  # This placeholder matches the one used in afl.


def create_cmd_instance(cmds, item):
    """Returns a command that is ready to be run.

    Args:
        cmds: A command as a list containing a placeholder @@ where item should
              be inserted before the command can be run.
        item: The item to take the place of the @@ placeholder in the command.
    Returns:
        The command as a list, now containing item.
    """
    cmd_copy = list(cmds)
    for i in range(len(cmd_copy)):
        if cmd_copy[i] == PLACEHOLDER:
            cmd_copy[i] = item
    return cmd_copy


def generate_single_crash_report(item, crash_dir, cmds):
    """Creates a single crash report for running the executable on item, by
    substututing item for the placeholder @@ in cmds, running the command
    represented by the updated cmds, and extracting information about the
    resulting crash.

    Args:
        item: The item to take the place of the @@ placeholder in the command.
        crash_dir: The directory containing crash inputs - <crash-inputs-dir>.
        cmds: A command as a list containing a placeholder @@
    Returns:
        A CrashReport object containing information about the crash caused by
        item.
    """
    cmd = create_cmd_instance(cmds, os.path.join(crash_dir, item))
    return create_crash_report(item, cmd)


def generate_crash_report_list(inputs, crash_dir, cmds):
    """Creates a crash report for every input file in crash_dir.

    cmds must contain the @@ placeholder, to indicate where each filename in
    inputs in turn should be inserted before the command is run.

    Args:
        inputs: A list of valid input files.
        crash_dir: The directory containing the input files -
                   <crash-inputs-dir>.
        cmds: A command as a list containing a placeholder @@
    Returns:
        A CrashReportList object containing a list of crash reports - one for
        every valid input file in <crash-inputs-dir>.
    """
    return [generate_single_crash_report(item, crash_dir, cmds)
            for item in inputs]


def get_crash_input_files(crash_dir, non_crashes):
    """Creates a list of valid crash input files.

    Files listed in non_crashes and directories are not valid crash input
    files.

    Args:
        crash_dir: The directory containing all possible input files -
                   <crash-inputs-dir>
        non_crashes: A list of files that should be specifically excluded from
                     the list of valid input files, if they exist in crash_dir.
    Returns:
        A list of file names.
    """
    if not os.path.isdir(crash_dir):
        return []

    inputs_raw = os.listdir(crash_dir)
    inputs = []
    for item in inputs_raw:
        if (os.path.isfile(os.path.join(crash_dir, item)) and
            item not in non_crashes):
            inputs.append(item)
    return inputs


def check_cmdline_args(args):
    """
    Will raise an exception if:
        - Not enough arguments are supplied.
        - The <crash-inputs-dir> supplied does not exist or does not contain
          any valid input files.
        - The executable supplied cannot be found.
        - The executable supplied is not executable.
        - There is no @@ placeholder in the command line arguments.

    Args:
        args: The command line arguments supplied when running the script,
              not including the script name itself.
    Returns:
        A tuple of (inputs, crash_dir, cmds):
            inputs: A list of valid inputs files for the executable.
            crash_dir: <crash-inputs-dir>
            cmds: The command as a list that will run the executable with the
                  supplied commind line arguments.  This list will contain
                  the @@ placeholder to represent where an input file should be
                  inserted.
    """
    if len(args) < 2:
        raise Exception("Error: Too few arguments.\n"
                        "Usage: /path/to/afl-crash-reports.py "
                        "<crash-inputs-dir> /path/to/executable/ "
                        "[...executable's cmdline options/arguments...]")

    crash_dir = os.path.normpath(args[0])
    inputs = get_crash_input_files(crash_dir, NON_CRASHES)
    if not inputs:
        raise Exception("Error: Unable to find input files in "
                        "{!s}/".format(crash_dir))

    if not os.path.isfile(args[1]):
        raise Exception("Error: Unable to find executable "
                        "{!s}".format(args[1]))

    if not os.access(args[1], os.X_OK):
        raise Exception("Error: {!s} is not executable.".format(args[1]))

    if PLACEHOLDER not in args[2:]:
        raise Exception("Error: No {!s} input file placeholder in executable's"
                        " cmdline arguments.".format(PLACEHOLDER))

    return inputs, crash_dir, args[1:]


def main(argv):
    """Checks the validity of the command line arguments then generates
    crash reports for the supplied executable.
    """
    try:
        inputs, crash_dir, cmds = check_cmdline_args(argv)
    except Exception as e:
        print >> sys.stderr, e
        sys.exit(1)

    crash_reports = generate_crash_report_list(inputs, crash_dir, cmds)

    for report in crash_reports:
        print report
    # TODO(katjoyce): Do something with crash reports!


if __name__ == '__main__':
    main(sys.argv[1:])
