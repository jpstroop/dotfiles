## Homebrew update check (runs once per 24 hours)
BREW_CHECK_STAMP="$HOME/.cache/brew_check.stamp"

# Create stamp file if needed (~/.cache should already exist)
[[ -e "$BREW_CHECK_STAMP" ]] || touch "$BREW_CHECK_STAMP"

# Check if stamp is older than 24 hours (-mtime +0 means modified more than 24h ago)
if [[ -n "$(find "$BREW_CHECK_STAMP" -mtime +0 2>/dev/null)" ]]; then
    print -P " %F{magenta}***%f Homebrew has not been checked in 24+ hours. Checking..."
    brew update >/dev/null 2>&1
    local outdated
    outdated=$(brew outdated -v)
    if [[ -n "$outdated" ]]; then
        print -P " %F{magenta}***%f The following packages can be upgraded:"
        while IFS= read -r line; do
            print -P "      %F{208}*%f $line"
        done <<< "$outdated"
    fi
    touch "$BREW_CHECK_STAMP"
fi
