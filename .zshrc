# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"


# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# VS Code to PATH
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

# Claude Code to PATH
export PATH="$HOME/.local/bin:$PATH"
# path=("${ASDF_DATA_DIR:-$HOME/.asdf}/shims" $path)

# Preferred editor
export EDITOR='code'

## Use GNU utilities instead of BSD
#   brew install coreutils diffutils ed findutils gawk gnu-sed gnu-tar gnu-which grep gzip watch wdiff wget
#
#   coreutils, diffutils, findutils, gawk, gnu-sed, gnu-tar, gnu-which, grep
#
# Packages without gnubin (just install to homebrew bin, already in PATH):
#   ed, gzip, watch, wdiff, wget

HOMEBREW_PREFIX="/opt/homebrew"

# Add gnubin directories to PATH (order matters - last added = highest priority)
path=(
    "${HOMEBREW_PREFIX}/opt/coreutils/libexec/gnubin"
    "${HOMEBREW_PREFIX}/opt/diffutils/libexec/gnubin"
    "${HOMEBREW_PREFIX}/opt/findutils/libexec/gnubin"
    "${HOMEBREW_PREFIX}/opt/gawk/libexec/gnubin"
    "${HOMEBREW_PREFIX}/opt/gnu-sed/libexec/gnubin"
    "${HOMEBREW_PREFIX}/opt/gnu-tar/libexec/gnubin"
    "${HOMEBREW_PREFIX}/opt/gnu-which/libexec/gnubin"
    "${HOMEBREW_PREFIX}/opt/grep/libexec/gnubin"
    $path
)

# ## ASDF version manager
# export ASDF_FORCE_PREPEND=1
path=("${ASDF_DATA_DIR:-$HOME/.asdf}/shims" $path)

# # Enable completions
mkdir -p "${ASDF_DATA_DIR:-$HOME/.asdf}/completions"
asdf completion zsh > "${ASDF_DATA_DIR:-$HOME/.asdf}/completions/_asdf"
fpath=(${ASDF_DATA_DIR:-$HOME/.asdf}/completions $fpath)
autoload -Uz compinit && compinit

# `asdf which` extension - adds an option to specify a version as the third arg
# to the which subcommand and get a path to the binary, e.g.:
#
#   ➜  ~$ asdf which python
#   /Users/jstroop/.asdf/installs/python/3.8.5/bin/python  # version in .tool-versions
#   ➜  ~$ asdf which python 3.7.6
#   /Users/jstroop/.asdf/installs/python/3.7.6/bin/python  # version from 3rd arg
#
# https://asdf-vm.com/manage/commands.html

ASDF_LANGS=("python")

function asdf() {
    if [[ "$1" == "which" && -n "$3" && ${ASDF_LANGS[(Ie)$2]} -gt 0 ]]; then
        local where
        where=$(command asdf where "$2" "$3")
        if [[ "$where" == "Version not installed" ]]; then
            echo "$where"
        else
            echo "$where/bin/$2"
        fi
    else
        command asdf "$@"
    fi
}

## Homebrew update check (runs once per 24 hours)
BREW_CHECK_STAMP="$HOME/.cache/brew_check.stamp"

# Create stamp file if needed (~/.cache should already exist)
[[ -e "$BREW_CHECK_STAMP" ]] || touch "$BREW_CHECK_STAMP"

# Check if stamp is older than 24 hours (-mtime +0 means modified more than 24h ago)
if [[ -n "$(find "$BREW_CHECK_STAMP" -mtime +0 2>/dev/null)" ]]; then
    print -P " %F{magenta}***%f Homebrew has not been checked in 24+ hours. Checking..."
    brew update >/dev/null 2>&1
    local outdated
    outdated=$(brew outdated -v)
    if [[ -n "$outdated" ]]; then
        print -P " %F{magenta}***%f The following packages can be upgraded:"
        while IFS= read -r line; do
            print -P "      %F{208}*%f $line"
        done <<< "$outdated"
    fi
    touch "$BREW_CHECK_STAMP"
fi


# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

