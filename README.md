# dotfiles

Personal zsh configuration for macOS with Oh My Zsh.

## Structure

```
.zprofile              # Homebrew bootstrap (runs at login, before .zshrc)
.zshrc                 # Oh My Zsh config + sources modular scripts
.zsh/
  prompt.zsh           # Prompt overrides (full relative path instead of dir name)
  environment.zsh      # LANG, EDITOR, PATH entries
  gnu-utils.zsh        # GNU coreutils/findutils/etc. PATH setup
  asdf.zsh             # asdf version manager + custom `which` extension
  aliases.zsh          # Custom shell aliases
  brew-check.zsh       # Daily Homebrew update check with upgrade prompt
Brewfile               # Homebrew packages (GNU utils, git, asdf, pdm, fonts)
install.sh             # Bootstrap script for a fresh machine
```

## Setup

Clone to `~/dotfiles` and run the install script:

```sh
git clone https://github.com/jpstroop/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
exec zsh
```

The install script will:
1. Install Xcode Command Line Tools (if not already present)
2. Install Homebrew packages from the Brewfile
3. Install Oh My Zsh (if not already present)
4. Symlink `.zprofile`, `.zshrc`, and `.zsh/` into your home directory
5. Back up any existing files before overwriting
6. Install asdf plugins (python, ruby), generate `.tool-versions` with latest versions on first run, and install them
7. Make deployed dotfiles read-only to prevent accidental edits

Homebrew itself must be installed first: https://brew.sh

## What's customized

### GNU coreutils over BSD

GNU coreutils, findutils, grep, sed, tar, and others are more full-featured
than the BSD versions that ship with macOS. This config installs them via
Homebrew and prepends them to `PATH` so they take precedence.
`LS_COLORS` is set via `dircolors` for colored `ls` output.

### asdf version manager

Adds asdf shims to `PATH` and sets up completions. Extends `asdf which` with an
optional third argument to look up the binary path for a specific version:

```sh
asdf which python 3.7.6
# /Users/you/.asdf/installs/python/3.7.6/bin/python
```

### Homebrew update check

On shell startup, if it's been more than 24 hours since the last check, runs
`brew update` and lists outdated packages with an interactive upgrade prompt.

### Prompt

Overrides the robbyrussell theme to show the full path relative to `$HOME`
(`%~`) instead of just the current directory name.

### Aliases

Overrides Oh My Zsh's `ls` alias to use GNU-compatible flags (`--color=auto`)
and show hidden files (`-a`).

## Development workflow

The deployed copy lives at `~/dotfiles`. Make changes in a separate working
copy (e.g. `~/workspace/dotfiles`), then push to GitHub and pull into the
deployed copy. The install script makes deployed files read-only, so accidental
edits there will fail with a permission error.

## Adding new modular configs

Create a new `.zsh` file in the `.zsh/` directory and add a source line to `.zshrc`:

```zsh
source "${0:A:h}/.zsh/my-new-config.zsh"
```

The `${0:A:h}` pattern resolves symlinks, so source paths work whether
`.zshrc` is accessed directly or via the `~/.zshrc` symlink.

## License

MIT
