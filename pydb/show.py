"""$Id: show.py,v 1.3 2006/07/25 14:15:43 rockyb Exp $
show subcommands, except those that need some sort of text substitution.
(Those are in gdb.py.in.)
"""
from fns import *

class SubcmdShow:

    """Handle set subcommands. This class isn't usuable in of itself,
    but is expected to be called with something that subclasses it and
    adds other methods and instance variables like msg and
    _program_sys_argv."""

    ######## Note: the docstrings of methods here get used in
    ######## help output.

    def show_args(self, args):
        """Show argument list to give debugged program when it is started.
Follow this command with any number of args, to be passed to the program."""
        self.msg("Argument list to give program being debugged " +
                 "when it is started is ")
        self.msg('"%s".' % " ".join(self._program_sys_argv[1:]))

    def show_basename(self, args):
        """Show if we are to show short of long filenames"""
        self.msg("basename is %s." % show_onoff(self.basename))

    def show_cmdtrace(self, args):
        "Show if we are to show debugger commands before running"
        self.msg("cmdtrace is %s." % show_onoff(self.cmdtrace))

    def show_directories(self, args):
        """Current search path for finding source files.
$cwd in search path means the current working directory.
$cdir in the path means the compilation directory of the source file."""
        self.msg("Source directories searched: %s." % self.search_path)

    def show_interactive(self, args):
        """Show whether we are interactive"""
        self.msg("interactive is %s." %
                 show_onoff(not self.noninteractive))

    def show_linetrace(self, args):
        "Show the line tracing status. Can also add 'delay'"
        self.msg("line tracing is %s." % show_onoff(self.linetrace))

    def show_logging(self, args):
        "Show logging options"
        if len(args) > 1 and args[1]:
            if args[1] == 'file':
                self.msg('The current logfile is "%s".' %
                         self.logging_file)
            elif args[1] == 'overwrite':
                self.msg('Whether logging overwrites or appends to the'
                         + ' log file is %s.'
                         % show_onoff(self.logging_overwrite))
            elif args[1] == 'redirect':
                self.msg('The logging output mode is %s.' %
                         show_onoff(self.logging_redirect))
            else:
                self.undefined_cmd("show logging", args[1])
        else:
            self.msg('Future logs will be written to %s.' % self.logging_file)
            if self.logging_overwrite:
                self.msg('Logs will overwrite the log file.')
            else:
                self.msg('Logs will be appended to the log file.')
            if self.logging_redirect:
                self.msg("Output will be sent only to the log file.")
            else:
                self.msg("Output will be logged and displayed.")