# ASDF version manager
path=("${ASDF_DATA_DIR:-$HOME/.asdf}/shims" $path)

# Enable completions (regenerate only if missing, e.g. after fresh install)
if [[ ! -f "${ASDF_DATA_DIR:-$HOME/.asdf}/completions/_asdf" ]]; then
    mkdir -p "${ASDF_DATA_DIR:-$HOME/.asdf}/completions"
    asdf completion zsh > "${ASDF_DATA_DIR:-$HOME/.asdf}/completions/_asdf"
fi
fpath=(${ASDF_DATA_DIR:-$HOME/.asdf}/completions $fpath)
autoload -Uz compinit && compinit

# `asdf which` extension - adds an option to specify a version as the third arg
# to the which subcommand and get a path to the binary, e.g.:
#
#   ➜  ~$ asdf which python
#   /Users/jstroop/.asdf/installs/python/3.8.5/bin/python  # version in .tool-versions
#   ➜  ~$ asdf which python 3.7.6
#   /Users/jstroop/.asdf/installs/python/3.7.6/bin/python  # version from 3rd arg
#
# https://asdf-vm.com/manage/commands.html

ASDF_LANGS=('python ruby')

function asdf() {
    if [[ "$1" == 'which' && -n "$3" && ${ASDF_LANGS[(Ie)$2]} -gt 0 ]]; then
        local where
        where=$(command asdf where "$2" "$3")
        if [[ "$where" == 'Version not installed' ]]; then
            echo "$where"
        else
            echo "$where/bin/$2"
        fi
    else
        command asdf "$@"
    fi
}
