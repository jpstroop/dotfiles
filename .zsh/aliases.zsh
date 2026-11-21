# Custom aliases (loaded after OMZ, so these override plugin aliases)

# Fix ls colors for GNU coreutils (OMZ sets -G which is BSD-only)
alias ls='ls -a --color=auto'

# Prevent zsh correction from suggesting .zsh directory
alias zsh='nocorrect zsh'

# Shortcut for starting Ollama
alias ollama-up='OLLAMA_FLASH_ATTENTION="1" OLLAMA_KV_CACHE_TYPE="q8_0" /opt/homebrew/opt/ollama/bin/ollama serve'

