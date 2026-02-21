# asdf language version check (runs once per 24 hours)
ASDF_CHECK_STAMP="$HOME/.cache/asdf_check.stamp"

# Create stamp file if needed (~/.cache should already exist)
[[ -e "$ASDF_CHECK_STAMP" ]] || touch "$ASDF_CHECK_STAMP"

# Check if stamp is older than 24 hours (-mtime +0 means modified more than 24h ago)
if [[ -n "$(find "$ASDF_CHECK_STAMP" -mtime +0 2>/dev/null)" ]]; then
    typeset -A _asdf_updates
    for _plugin in python ruby; do
        local _current
        _current=$(awk "/^${_plugin} /{print \$2}" "$HOME/.tool-versions")
        local _latest
        if [[ "$_plugin" == 'python' ]]; then
            _latest=$(asdf latest python)
            # Avoid free-threaded builds (versions ending in "t") -- most tooling
            # doesn't support the no-GIL builds yet
            if [[ "$_latest" == *t ]]; then
                _latest=$(asdf list all python | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | tail -1)
            fi
        else
            _latest=$(asdf latest "$_plugin")
        fi
        if [[ "$_current" != "$_latest" ]]; then
            _asdf_updates[$_plugin]="$_latest"
            print -P " %F{yellow}!!!%f $_plugin: $_current → $_latest available"
        fi
    done

    if (( ${#_asdf_updates[@]} > 0 )); then
        print -n " Update .tool-versions and install? [y/N] "
        read -r _response
        if [[ "$_response" =~ ^[Yy]$ ]]; then
            local _tmp
            _tmp=$(mktemp)
            while IFS= read -r _line; do
                local _p="${_line%% *}"
                if (( ${+_asdf_updates[$_p]} )); then
                    print "$_p ${_asdf_updates[$_p]}"
                else
                    print "$_line"
                fi
            done < "$HOME/.tool-versions" > "$_tmp"
            mv "$_tmp" "$HOME/.tool-versions"
            asdf install
        fi
    fi

    touch "$ASDF_CHECK_STAMP"
fi

unset _asdf_updates _plugin _current _latest _response _tmp _line _p
