# Environment variables and PATH configuration

export LANG=en_US.UTF-8
export EDITOR='code'

# Homebrew Bundle: skip Go packages. Go is managed by asdf, and brew runs the
# asdf shim with a sanitized PATH where `asdf` isn't found (exit 127).
export HOMEBREW_BUNDLE_DUMP_NO_GO=1
export HOMEBREW_BUNDLE_CLEANUP_NO_GO=1

# VS Code
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

# Claude Code
export PATH="$HOME/.local/bin:$PATH"

# Google Cloud SDK
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi

# Shell command completion for gcloud
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi