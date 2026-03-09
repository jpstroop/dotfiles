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
  asdf-check.zsh       # Daily check for newer stable python/ruby versions
.ssh/
  config               # Include directive and global Host * defaults
  config.d/
    github             # SSH config for github.com (add work hosts locally, not here)
Brewfile               # Homebrew packages (GNU utils, git, asdf, pdm, fonts)
install.sh             # Bootstrap script for a fresh machine
update.sh              # Sync packages/tool versions after pulling new dotfile commits
macos.sh               # System customizations (called by install.sh and update.sh)
iterm2/
  jstroop.json         # iTerm2 profile (symlinked to ~/Library/.../DynamicProfiles/)
export.sh              # Export sensitive keys and secrets to an encrypted bundle
import.sh              # Import an encrypted bundle from export.sh
```

## Setup

### Fresh machine

1. Install Xcode Command Line Tools (provides `git`):
   ```sh
   xcode-select --install
   ```
2. Install Homebrew:
   ```sh
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
3. Install `gnupg` (needed to decrypt the export bundle):
   ```sh
   brew install gnupg
   ```
4. Clone via HTTPS (no SSH keys yet):
   ```sh
   git clone https://github.com/jpstroop/dotfiles.git ~/dotfiles
   ```
5. If moving from another machine, transfer the export bundle and run [`import.sh`](import.sh) to restore SSH keys, GPG keys, and secrets:
   ```sh
   ~/dotfiles/import.sh
   ```
6. Run [`install.sh`](install.sh):
   ```sh
   ~/dotfiles/install.sh
   exec zsh
   ```

[`install.sh`](install.sh) will:
1. Install Homebrew packages from the Brewfile
2. Install Oh My Zsh (if not already present)
3. Symlink `.zprofile`, `.zshrc`, and `.zsh/` into your home directory
4. Back up any existing files before overwriting
5. Install asdf plugins (python, ruby), generate `.tool-versions` with latest versions on first run, and install them
6. Symlink `.gitignore_global`, `.gitconfig`, and `.ssh/config`
7. Symlink `.ssh/config.d/github` and public keys
8. Symlink iTerm2 Dynamic Profile to `~/Library/Application Support/iTerm2/DynamicProfiles/`
9. Apply macOS customizations via [`macos.sh`](macos.sh)
10. Make deployed dotfiles read-only to prevent accidental edits

## What's customized

### GNU coreutils over BSD

GNU coreutils, findutils, grep, sed, tar, and others are more full-featured
than the BSD versions that ship with macOS. We nstall them via Homebrew and 
prepend them to `PATH` so they take precedence. `LS_COLORS` is set via 
`dircolors` for colored `ls` output.

### asdf version manager

Adds asdf shims to `PATH` and sets up completions. We also extend `asdf which` 
with an optional third argument to look up the executable path for a specific 
version:

This makes it possible to run scripts with a specific version of python without
messing around with `.tool-versions`, shims, paths, etc, e.g.:

```sh
$(asdf which python 3.14.3) -c "from sys import version_info as v; print(f'Hello from Python {v.major}.{v.minor}.{v.micro}')"
Hello from Python 3.14.3

$(asdf which python 3.11.14) -c "from sys import version_info as v; print(f'Hello from Python {v.major}.{v.minor}.{v.micro}')"
Hello from Python 3.11.14
```

### Daily automated checks

On shell startup, two checks run if it's been more than 24 hours since they last ran (each has its own stamp file in `~/.cache/`):

- **[`brew-check.zsh`](.zsh/brew-check.zsh)** — runs `brew update` and lists outdated packages with an interactive upgrade prompt
- **[`asdf-check.zsh`](.zsh/asdf-check.zsh)** — checks for newer stable python and ruby releases and prompts to update `~/.tool-versions` and install

### Manual sync (`update.sh`)

After pulling new commits, run [`update.sh`](update.sh) to sync everything:

- `brew bundle` — installs any packages added to the Brewfile
- SSH public key symlinks — picks up any new `.pub` files added to the repo
- `asdf install` — installs any tool versions added to `.tool-versions`

```sh
git -C ~/dotfiles pull
~/dotfiles/update.sh
```

### Prompt

Overrides the robbyrussell theme to show the full path relative to `$HOME`
(`%~`) instead of just the current directory name.

### Aliases

Overrides Oh My Zsh's `ls` alias to use GNU-compatible flags (`--color=auto`)
and show hidden files (`-a`).

## System customizations

[`macos.sh`](macos.sh) is run automatically by [`install.sh`](install.sh) and [`update.sh`](update.sh). Currently:

- Hides cluttering home directory folders from Finder (Music, Pictures, Public, Movies, Documents)
- Sets key repeat to maximum speed
- Always shows file extensions; disables extension change warning
- New Finder windows open to home directory
- Shows path bar in Finder; sets default view to list
- Disables recent apps in Dock
- Saves screenshots to `~/screenshots`; disables drop shadow
- Saves new documents to disk instead of iCloud
- Requires password immediately after screensaver
- Disables `.DS_Store` creation on network and USB volumes

To reverse the hidden folders:

```sh
chflags nohidden ~/Music
```

## Moving to a new machine

On the old machine, run [`export.sh`](export.sh) to create an encrypted bundle:

```sh
~/dotfiles/export.sh
```

It will prompt for an output path (defaults to `~/Desktop/dotfiles-export-<date>.tgz.gpg`)
and a passphrase. The bundle contains:

- SSH private keys
- Local `~/.ssh/config.d/` fragments (non-versioned ones like `work`)
- GPG private keys and owner trust
- `~/.secrets`

Transfer the bundle to the new machine (AirDrop, USB, etc.), then run
[`import.sh`](import.sh):

```sh
~/dotfiles/import.sh
```

It will prompt for the bundle path and passphrase, restore all files to the
correct locations with correct permissions, and add the SSH key to the agent.
Run [`install.sh`](install.sh) afterwards if it's a fresh machine.

## Development workflow

The deployed copy lives at `~/dotfiles`. Make changes in a separate working
copy (e.g. `~/workspace/dotfiles`), then push to GitHub and pull into the
deployed copy. The install script makes deployed files read-only, so accidental
edits are less likely.

## Adding new scripts

Create a new `.zsh` file in the `.zsh/` directory and add a source line to `.zshrc`:

```zsh
source "${0:A:h}/.zsh/my-new-config.zsh"
```

The `${0:A:h}` pattern resolves symlinks, so source paths work whether
`.zshrc` is accessed directly or via the `~/.zshrc` symlink.

## SSH config / Key generation notes

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
and must be set up manually after running [`install.sh`](install.sh).

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

**Never** add private keys or `known_hosts` to this repo. The root
`.gitignore` ignores everything in `.ssh/` except `config.d/github` and `*.pub` files.

## Secrets and private environment variables

`~/.secrets` is sourced at the end of `.zshrc` for private environment
variables. It lives outside this repo and is created empty (mode `600`)
by [`install.sh`](install.sh).

```sh
# ~/.secrets
export GITHUB_TOKEN='ghp_...'
export AWS_ACCESS_KEY_ID='...'
```

**Do not** add `~/.secrets` to the repo.

## License

[MIT](LICENSE)
