# Custom aliases (loaded after OMZ, so these override plugin aliases)

# Fix ls colors for GNU coreutils (OMZ sets -G which is BSD-only)
alias ls='ls -a --color=auto'

# Prevent zsh correction from suggesting .zsh directory
alias zsh='nocorrect zsh'
