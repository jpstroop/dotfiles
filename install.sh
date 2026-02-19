#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"

info() { printf ' \033[35m***\033[0m %s\n' "$1"; }
warn() { printf ' \033[33m!!!\033[0m %s\n' "$1"; }
ok()   { printf ' \033[32m ✓ \033[0m %s\n' "$1"; }

# Verify we're running from the right place
if [[ ! -f "$DOTFILES_DIR/install.sh" ]]; then
    warn "Expected dotfiles repo at $DOTFILES_DIR"
    warn "Clone the repo there first: git clone <repo-url> $DOTFILES_DIR"
    exit 1
fi

# 1. Check for Xcode Command Line Tools
info 'Checking for Xcode Command Line Tools...'
if xcode-select -p &>/dev/null; then
    ok 'Xcode Command Line Tools found'
else
    info 'Installing Xcode Command Line Tools (follow the dialog)...'
    xcode-select --install
    warn 'Waiting for installation to complete. Re-run this script when done.'
    exit 0
fi

# 2. Check for Homebrew
info 'Checking for Homebrew...'
if ! command -v brew &>/dev/null; then
    warn 'Homebrew is not installed.'
    warn 'Install it first: https://brew.sh'
    exit 1
fi
ok 'Homebrew found'

# 3. Install Homebrew packages
info 'Installing Homebrew packages from Brewfile...'
brew bundle --file="$DOTFILES_DIR/Brewfile"
ok 'Homebrew packages installed'

# 4. Install Oh My Zsh
info 'Checking for Oh My Zsh...'
if [[ -d "$HOME/.oh-my-zsh" ]]; then
    ok 'Oh My Zsh already installed'
else
    info 'Installing Oh My Zsh...'
    # RUNZSH=no  — don't launch zsh after install
    # KEEP_ZSHRC=yes — don't overwrite .zshrc (we'll symlink ours)
    RUNZSH=no KEEP_ZSHRC=yes sh -c \
        "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    ok 'Oh My Zsh installed'
fi

# 5. Symlink .zprofile
info 'Symlinking .zprofile...'
if [[ -f "$HOME/.zprofile" && ! -L "$HOME/.zprofile" ]]; then
    mv "$HOME/.zprofile" "$HOME/.zprofile.bak"
    warn "Existing .zprofile backed up to ~/.zprofile.bak"
fi
ln -sfn "$DOTFILES_DIR/.zprofile" "$HOME/.zprofile"
ok '.zprofile symlinked'

# 6. Symlink .zshrc
info 'Symlinking .zshrc...'
if [[ -f "$HOME/.zshrc" && ! -L "$HOME/.zshrc" ]]; then
    mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
    warn "Existing .zshrc backed up to ~/.zshrc.bak"
fi
ln -sfn "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
ok '.zshrc symlinked'

# 7. Symlink .zsh/ directory
info 'Symlinking .zsh/ directory...'
if [[ -d "$HOME/.zsh" && ! -L "$HOME/.zsh" ]]; then
    mv "$HOME/.zsh" "$HOME/.zsh.bak"
    warn "Existing .zsh/ backed up to ~/.zsh.bak"
fi
ln -sfn "$DOTFILES_DIR/.zsh" "$HOME/.zsh"
ok '.zsh/ symlinked'

# 8. Install asdf plugins
for plugin in python ruby; do
    if asdf plugin list 2>/dev/null | grep -q "$plugin"; then
        ok "asdf $plugin plugin already installed"
    else
        info "Installing asdf $plugin plugin..."
        asdf plugin add "$plugin"
        ok "asdf $plugin plugin installed"
    fi
done

# 9. Generate .tool-versions if it doesn't exist
TOOL_VERSIONS="$DOTFILES_DIR/.tool-versions"
if [[ -f "$TOOL_VERSIONS" ]]; then
    ok '.tool-versions already exists'
else
    info 'Resolving latest tool versions...'
    for plugin in python ruby; do
        version=$(asdf latest "$plugin")
        # Avoid free-threaded Python builds (versions ending in "t") --
        # most tooling doesn't support the no-GIL builds yet
        if [[ "$version" == *t ]]; then
            version=$(asdf list all "$plugin" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | tail -1)
        fi
        echo "$plugin $version" >> "$TOOL_VERSIONS"
        ok "$plugin $version"
    done
fi
ln -sfn "$TOOL_VERSIONS" "$HOME/.tool-versions"
ok '.tool-versions symlinked'

# 10. Install tool versions from .tool-versions
info 'Installing asdf tool versions (this may take a few minutes)...'
asdf install
ok 'Tool versions installed'

# 11. Ensure ~/.cache exists (used by brew-check.zsh)
mkdir -p "$HOME/.cache"

# 12. Create ~/.secrets if it doesn't exist
if [[ ! -f "$HOME/.secrets" ]]; then
    touch "$HOME/.secrets"
    chmod 600 "$HOME/.secrets"
    ok 'Created ~/.secrets (add private environment variables here)'
else
    ok '~/.secrets already exists'
fi

# 13. Make deployed dotfiles read-only to prevent accidental edits
info 'Making deployed dotfiles read-only...'
chmod a-w "$DOTFILES_DIR/.zprofile" "$DOTFILES_DIR/.zshrc"
find "$DOTFILES_DIR/.zsh" -type f -exec chmod a-w {} +
ok 'Deployed dotfiles are now read-only'

echo ''
info 'Done! Run `exec zsh` to reload your shell.'
