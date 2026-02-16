# Use GNU utilities instead of BSD
# To install GNU utilities, run: 
#   brew install coreutils diffutils ed findutils gawk gnu-sed gnu-tar gnu-which grep gzip watch wdiff wget

HOMEBREW_PREFIX="/opt/homebrew"

# Add gnubin directories to PATH (order matters - last added = highest priority)
path=(
    "${HOMEBREW_PREFIX}/opt/coreutils/libexec/gnubin"
    "${HOMEBREW_PREFIX}/opt/diffutils/libexec/gnubin"
    "${HOMEBREW_PREFIX}/opt/findutils/libexec/gnubin"
    "${HOMEBREW_PREFIX}/opt/gawk/libexec/gnubin"
    "${HOMEBREW_PREFIX}/opt/gnu-sed/libexec/gnubin"
    "${HOMEBREW_PREFIX}/opt/gnu-tar/libexec/gnubin"
    "${HOMEBREW_PREFIX}/opt/gnu-which/libexec/gnubin"
    "${HOMEBREW_PREFIX}/opt/grep/libexec/gnubin"
    $path
)
