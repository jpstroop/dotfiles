# Oh My Zsh (OMZ) configuration
# Everything in this section must come BEFORE `source $ZSH/oh-my-zsh.sh`
# because OMZ reads these variables during initialization.
# Personal customizations (aliases, PATH, functions) go AFTER the source line
# so they can override anything OMZ or its plugins set up.

export ZSH="$HOME/.oh-my-zsh"

# OMZ theme — controls prompt appearance (colors, git status, layout)
# See available themes: https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# Set to "random" to pick a new theme each session
ZSH_THEME='robbyrussell'

# When ZSH_THEME="random", restrict to these themes:
# ZSH_THEME_RANDOM_CANDIDATES=("robbyrussell" "agnoster")

# OMZ auto-update: "auto" (silent), "reminder" (nag), or "disabled"
zstyle ':omz:update' mode auto
# zstyle ':omz:update' frequency 13  # days between update checks

# Case-sensitive tab completion (default: case-insensitive)
# CASE_SENSITIVE="true"

# Treat hyphens and underscores as interchangeable in completion
# (only works when CASE_SENSITIVE is not "true")
# HYPHEN_INSENSITIVE="true"

# Disable URL auto-escaping on paste (fix if pasting is slow or broken)
# DISABLE_MAGIC_FUNCTIONS="true"

# Disable colored ls output
# DISABLE_LS_COLORS="true"

# Disable auto-setting terminal window/tab title to current dir or command
# DISABLE_AUTO_TITLE="true"

# Enable "did you mean X?" correction for mistyped commands
ENABLE_CORRECTION="true"

# Show dots (or custom string) while waiting for slow completions
# COMPLETION_WAITING_DOTS="true"
# COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"

# Skip untracked-file checks in git repos (faster prompt in large repos)
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Date format in `history` output: "mm/dd/yyyy", "dd.mm.yyyy", "yyyy-mm-dd",
# or any strftime format string
# HIST_STAMPS="yyyy-mm-dd"

# Custom config directory (default: $ZSH/custom)
# Files in this dir are auto-sourced; themes go in themes/, plugins in plugins/
# ZSH_CUSTOM=/path/to/custom-folder

# OMZ plugins — adds aliases, completions, and functions
# Available: https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins
# Each one adds to shell startup time, so be selective
plugins=(git)

# Initialize OMZ (loads plugins, theme, completions, key bindings)
source $ZSH/oh-my-zsh.sh

# Source modular configs (personal customizations, loaded after OMZ)
source "${0:A:h}/.zsh/prompt.zsh"
source "${0:A:h}/.zsh/environment.zsh"
source "${0:A:h}/.zsh/gnu-utils.zsh"
source "${0:A:h}/.zsh/asdf.zsh"
source "${0:A:h}/.zsh/aliases.zsh"
source "${0:A:h}/.zsh/brew-check.zsh"
