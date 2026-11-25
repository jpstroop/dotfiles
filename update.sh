#!/usr/bin/env zsh
set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"

info() { printf ' \033[35m***\033[0m %s\n' "$1"; }
ok()   { printf ' \033[32m ✓ \033[0m %s\n' "$1"; }
warn() { printf ' \033[33m!!!\033[0m %s\n' "$1"; }

# 1. Sync Homebrew packages
info 'Syncing Homebrew packages...'
brew bundle --file="$DOTFILES_DIR/Brewfile"
ok 'Homebrew packages synced'

# 3. Sync SSH public key symlinks
info 'Syncing SSH public key symlinks...'
for pubkey in "$DOTFILES_DIR"/.ssh/*.pub; do
    ln -sfn "$pubkey" "$HOME/.ssh/$(basename "$pubkey")"
done
ok 'SSH public keys synced'

# 3b. Sync Claude Code agent symlinks
info 'Syncing Claude Code agent symlinks...'
mkdir -p "$HOME/.claude/agents"
for agent in "$DOTFILES_DIR"/agents/*.md(N); do
    target="$HOME/.claude/agents/$(basename "$agent")"
    if [[ -f "$target" && ! -L "$target" ]]; then
        mv "$target" "$target.bak"
        warn "Existing $(basename "$agent") backed up to $target.bak"
    fi
    ln -sfn "$agent" "$target"
done
ok 'Claude Code agents synced'

# 4. Install any new asdf tool versions
info 'Syncing asdf tool versions from ~/.tool-versions...'
(cd "$HOME" && asdf install)
ok 'asdf tool versions synced'

# 5. Apply macOS customizations
"$DOTFILES_DIR/macos.sh"

echo ''
info 'Done! Run `exec zsh` to reload your shell.'
