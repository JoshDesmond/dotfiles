Dotfiles bash/scripts — convention for personal commands
==========================================================

These scripts are exposed as shell commands via ~/.bash_personal_config: each
executable *.sh is aliased to its basename without ".sh".

1) HELP BLOCK (first thing after the shebang)
---------------------------------------------
Line 1 MUST be the shebang (e.g. #!/usr/bin/env bash). The kernel requires it.

Immediately after that, a contiguous block of full-line comments (# ...). Do not
put a lone "#" line before the purpose line. The first #-comment line after the
shebang MUST be a one-line purpose in this form:

  # <script-basename.sh> — <single clear sentence describing what it does>

Then optional lines (still each starting with #): usage, flags, behavior notes,
host assumptions, etc. Do not put a blank non-# line inside this block; a gap
ends the block for tooling.

Use "#" alone on a line for an intentional blank line inside the help text.

2) --help and -h
----------------
Every script MUST respond to --help and -h (as the first argument), print the
same human-oriented text as the help block (without the leading # markers),
and exit 0.

Suggested pattern (copy into each script after the help block, before other
logic):

  case "${1:-}" in
  --help|-h)
  	awk 'NR==1{next} /^#/{sub(/^#[[:space:]]*/, ""); print; next} {exit}' "$0"
  	exit 0
  	;;
  esac

3) Arguments
------------
If the script expects arguments, document them in the help block. Prefer
printing a short usage message to stderr and exiting non-zero when required
arguments are missing (in addition to supporting --help).

4) Naming files
---------------
Default: kebab-case (e.g. my-tool.sh → command my-tool). PascalCase or other
forms are allowed when you are intentionally mirroring another environment
(e.g. a PowerShell-style name). Pick names that read as verbs or tools.
