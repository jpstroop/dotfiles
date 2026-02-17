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
1. Install Homebrew packages from the Brewfile
2. Install Oh My Zsh (if not already present)
3. Symlink `.zprofile`, `.zshrc`, and `.zsh/` into your home directory
4. Back up any existing files before overwriting
5. Make deployed dotfiles read-only to prevent accidental edits

Homebrew itself must be installed first: https://brew.sh

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
