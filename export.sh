#!/usr/bin/env zsh
set -euo pipefail

info()   { printf ' \033[35m***\033[0m %s\n' "$1"; }
warn()   { printf ' \033[33m!!!\033[0m %s\n' "$1"; }
ok()     { printf ' \033[32m ✓ \033[0m %s\n' "$1"; }
prompt() { printf ' \033[35m***\033[0m %s ' "$1"; } # no newline; user input follows on the same line

default_output="$HOME/Desktop/dotfiles-export-$(date +%Y%m%d).tgz.gpg"
prompt "Output file [$default_output]:"
read -r output_path
output_path="${output_path:-$default_output}"

tmp=$(mktemp -d)
trap "rm -rf $tmp" EXIT

# SSH private keys
info 'Collecting SSH private keys...'
mkdir -p "$tmp/ssh"
for key in ~/.ssh/id_*(N); do
    [[ "$key" == *.pub ]] && continue
    cp "$key" "$tmp/ssh/"
    ok "$(basename "$key")"
done

# Local SSH config.d fragments (skip symlinks — those are versioned in dotfiles)
info 'Collecting local SSH config fragments...'
mkdir -p "$tmp/ssh/config.d"
for fragment in ~/.ssh/config.d/*(N); do
    [[ -L "$fragment" ]] && continue
    cp "$fragment" "$tmp/ssh/config.d/"
    ok "config.d/$(basename "$fragment")"
done

# GPG private keys
info 'Collecting GPG keys...'
mkdir -p "$tmp/gpg"
if gpg --list-secret-keys --keyid-format LONG 2>/dev/null | grep -q '^sec'; then
    gpg --export-secret-keys --armor > "$tmp/gpg/private-keys.asc"
    gpg --export-ownertrust > "$tmp/gpg/owner-trust.txt"
    ok 'GPG keys exported'
else
    warn 'No GPG secret keys found, skipping'
fi

# ~/.secrets
info 'Collecting ~/.secrets...'
if [[ -f ~/.secrets && -s ~/.secrets ]]; then
    cp ~/.secrets "$tmp/secrets"
    ok '~/.secrets'
else
    warn '~/.secrets is empty or missing, skipping'
fi

# Encrypt
info 'Creating encrypted bundle (you will be prompted for a passphrase)...'
tar -czf - -C "$tmp" . | gpg --symmetric --armor --output "$output_path"
ok "Bundle saved to $output_path"

echo ''
info "Transfer $output_path to your new machine and run import.sh"
