# Prompt overrides (loaded after OMZ theme)
#
# The robbyrussell theme uses %c (current dir name only) by default.
# Override to use %~ (full path relative to $HOME) for more context.
#
# Zsh prompt path options:
#   %c or %1~  — current directory name only (e.g. "src")
#   %~         — path relative to $HOME with ~ substitution (e.g. "~/workspace/project/src")
#   %d or %/   — absolute path (e.g. "/Users/jstroop/workspace/project/src")
#   %2~        — last 2 path components (e.g. "project/src")

PROMPT="%(?:%{$fg_bold[green]%}%1{➜%} :%{$fg_bold[red]%}%1{➜%} ) %{$fg[cyan]%}%~%{$reset_color%}"
PROMPT+=' $(git_prompt_info)'
