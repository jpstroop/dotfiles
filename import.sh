#!/usr/bin/env zsh
set -euo pipefail

info()   { printf ' \033[35m***\033[0m %s\n' "$1"; }
warn()   { printf ' \033[33m!!!\033[0m %s\n' "$1"; }
ok()     { printf ' \033[32m ✓ \033[0m %s\n' "$1"; }
prompt() { printf ' \033[35m***\033[0m %s ' "$1"; } # no newline; user input follows on the same line

prompt 'Bundle path:'
read -r bundle_path
if [[ ! -f "$bundle_path" ]]; then
    warn "File not found: $bundle_path"
    exit 1
fi

tmp=$(mktemp -d)
trap "rm -rf $tmp" EXIT

info 'Decrypting bundle (you will be prompted for the passphrase)...'
gpg --decrypt "$bundle_path" | tar -xzf - -C "$tmp"
ok 'Bundle decrypted and extracted'

# SSH private keys
info 'Restoring SSH private keys...'
mkdir -p ~/.ssh
chmod 700 ~/.ssh
for key in "$tmp"/ssh/*(N); do
    [[ -d "$key" ]] && continue
    dest="$HOME/.ssh/$(basename "$key")"
    if [[ -f "$dest" ]]; then
        mv "$dest" "${dest}.bak"
        warn "Backed up existing $(basename "$dest")"
    fi
    cp "$key" "$dest"
    chmod 600 "$dest"
    ok "$(basename "$key")"
done

# Local SSH config.d fragments
if [[ -d "$tmp/ssh/config.d" ]] && (( $(ls "$tmp/ssh/config.d" | wc -l) > 0 )); then
    info 'Restoring local SSH config fragments...'
    mkdir -p ~/.ssh/config.d
    for fragment in "$tmp"/ssh/config.d/*(N); do
        dest="$HOME/.ssh/config.d/$(basename "$fragment")"
        if [[ -f "$dest" ]]; then
            mv "$dest" "${dest}.bak"
            warn "Backed up existing $(basename "$fragment")"
        fi
        cp "$fragment" "$dest"
        ok "config.d/$(basename "$fragment")"
    done
fi

# GPG keys
if [[ -f "$tmp/gpg/private-keys.asc" ]]; then
    info 'Restoring GPG keys...'
    gpg --import "$tmp/gpg/private-keys.asc"
    gpg --import-ownertrust "$tmp/gpg/owner-trust.txt"
    ok 'GPG keys imported'
fi

# ~/.secrets
if [[ -f "$tmp/secrets" ]]; then
    info 'Restoring ~/.secrets...'
    if [[ -f ~/.secrets && -s ~/.secrets ]]; then
        mv ~/.secrets ~/.secrets.bak
        warn 'Backed up existing ~/.secrets'
    fi
    cp "$tmp/secrets" ~/.secrets
    chmod 600 ~/.secrets
    ok '~/.secrets restored'
fi

# Add SSH key to agent
if [[ -f ~/.ssh/id_ed25519 ]]; then
    info 'Adding SSH key to agent...'
    ssh-add --apple-use-keychain ~/.ssh/id_ed25519
    ok 'SSH key added to agent'
fi

echo ''
info 'Done! Run install.sh if this is a fresh machine, or exec zsh to reload your shell.'
