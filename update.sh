#!/usr/bin/env zsh
set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"

info() { printf ' \033[35m***\033[0m %s\n' "$1"; }
ok()   { printf ' \033[32m ✓ \033[0m %s\n' "$1"; }

# 1. Pull latest dotfiles
info 'Pulling latest dotfiles...'
git -C "$DOTFILES_DIR" pull
ok 'Dotfiles up to date'

# 2. Sync Homebrew packages
info 'Syncing Homebrew packages...'
brew bundle --file="$DOTFILES_DIR/Brewfile"
ok 'Homebrew packages synced'

# 3. Install any new asdf tool versions
info 'Syncing asdf tool versions...'
asdf install
ok 'asdf tool versions synced'

echo ''
info 'Done! Run `exec zsh` to reload your shell.'
