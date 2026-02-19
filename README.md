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
.ssh/
  config.d/
    github             # SSH config for github.com (add work hosts locally, not here)
Brewfile               # Homebrew packages (GNU utils, git, asdf, pdm, fonts)
install.sh             # Bootstrap script for a fresh machine
update.sh              # Pull latest and sync packages/tool versions
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
7. Symlink `.ssh/config.d/github` and add an `Include` directive to `~/.ssh/config`
8. Make deployed dotfiles read-only to prevent accidental edits

Homebrew itself must be installed first: https://brew.sh

## What's customized

### GNU coreutils over BSD

GNU coreutils, findutils, grep, sed, tar, and others are more full-featured
than the BSD versions that ship with macOS. This config installs them via
Homebrew and prepends them to `PATH` so they take precedence.
`LS_COLORS` is set via `dircolors` for colored `ls` output.

### asdf version manager

Adds asdf shims to `PATH` and sets up completions. Extends `asdf which` with an
optional third argument to look up the executable path for a specific version:

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

## SSH config

`~/.ssh/config` uses the `Include` directive to load fragments from `~/.ssh/config.d/`.
Only `github` is versioned here. Machine-specific hosts go in additional files in
`~/.ssh/config.d/` and are never committed:

```sh
# Create a new fragment for work hosts (example)
cat > ~/.ssh/config.d/work << 'EOF'
Host bastion
    HostName bastion.example.com
    User jstroop
    IdentityFile ~/.ssh/id_ed25519
    ForwardAgent yes

Host dev
    HostName dev.example.com
    User jstroop
    ProxyJump bastion
EOF
```

Public keys (`.pub`) are versioned for reference. Private keys are never committed
and must be set up manually after running `install.sh`.

**On a new machine** (generate fresh keys, then register the public key with GitHub/servers):

```sh
ssh-keygen -t ed25519 -C "your@email.com"
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

**On a replacement machine** (transfer keys from the old machine):

```sh
scp old-machine:~/.ssh/id_ed25519 ~/.ssh/
chmod 600 ~/.ssh/id_ed25519
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

`--apple-use-keychain` stores the passphrase in macOS Keychain so you are not
prompted on every reboot.

**Security warning:** Never add private keys or `known_hosts` to this repo. The root
`.gitignore` ignores everything in `.ssh/` except `config.d/github` and `*.pub` files.

## Secrets and private environment variables

`~/.secrets` is sourced at the end of `.zshrc` for private environment
variables. It lives outside this repo and is created empty (mode `600`)
by the install script.

```sh
# ~/.secrets
export GITHUB_TOKEN='ghp_...'
export AWS_ACCESS_KEY_ID='...'
```

**Security warning:** Do not add `~/.secrets` or its contents to this repo.

## License

MIT
