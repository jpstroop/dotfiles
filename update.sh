#!/usr/bin/env zsh
set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"

info()   { printf ' \033[35m***\033[0m %s\n' "$1"; }
warn()   { printf ' \033[33m!!!\033[0m %s\n' "$1"; }
ok()     { printf ' \033[32m ✓ \033[0m %s\n' "$1"; }
prompt() { printf ' \033[35m***\033[0m %s ' "$1"; } # no newline; user input follows on the same line

# 1. Pull latest dotfiles
info 'Pulling latest dotfiles...'
git -C "$DOTFILES_DIR" pull
ok 'Dotfiles up to date'

# 2. Sync Homebrew packages
info 'Syncing Homebrew packages...'
brew bundle --file="$DOTFILES_DIR/Brewfile"
ok 'Homebrew packages synced'

# 3. Sync SSH public key symlinks
info 'Syncing SSH public key symlinks...'
for pubkey in "$DOTFILES_DIR"/.ssh/*.pub; do
    ln -sfn "$pubkey" "$HOME/.ssh/$(basename "$pubkey")"
done
ok 'SSH public keys synced'

# 4. Install any new asdf tool versions
info 'Syncing asdf tool versions...'
asdf install
ok 'asdf tool versions synced'

# 5. Check for newer stable language versions
info 'Checking for language version updates...'
typeset -A updates
for plugin in python ruby; do
    current=$(awk "/^${plugin} /{print \$2}" "$HOME/.tool-versions")
    if [[ "$plugin" == 'python' ]]; then
        latest=$(asdf latest python)
        if [[ "$latest" == *t ]]; then
            latest=$(asdf list all python | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | tail -1)
        fi
    else
        latest=$(asdf latest "$plugin")
    fi
    if [[ "$current" != "$latest" ]]; then
        updates[$plugin]="$latest"
        warn "$plugin: $current → $latest available"
    fi
done

if (( ${#updates[@]} > 0 )); then
    echo ''
    prompt 'Update .tool-versions and install? [y/N]'
    read -r answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        tmp=$(mktemp)
        while IFS= read -r line; do
            p="${line%% *}"
            if (( ${+updates[$p]} )); then
                print "$p ${updates[$p]}"
            else
                print "$line"
            fi
        done < "$DOTFILES_DIR/.tool-versions" > "$tmp"
        mv "$tmp" "$DOTFILES_DIR/.tool-versions"
        asdf install
        ok 'Language versions updated'
    fi
else
    ok 'Language versions are up to date'
fi

echo ''
info 'Done! Run `exec zsh` to reload your shell.'
