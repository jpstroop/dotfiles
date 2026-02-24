#!/usr/bin/env zsh
set -euo pipefail

ok() { printf ' \033[32m ✓ \033[0m %s\n' "$1"; }

# Hide cluttering home directory folders from Finder
# To reverse: chflags nohidden <dirname>
for dir in Music Pictures Public Movies Documents; do
    chflags hidden "$HOME/$dir"
    ok "Hidden ~/$dir"
done

# Key repeat speed (units are 1/60s; lower = faster; macOS default is 6/25)
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10
ok 'Key repeat speed set'

# Finder
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
ok 'Always show file extensions'
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
ok 'Disabled file extension change warning'
defaults write com.apple.finder NewWindowTarget -string 'PfHm'
ok 'New Finder windows open to home directory'
defaults write com.apple.finder ShowPathbar -bool true
ok 'Finder path bar enabled'
defaults write com.apple.finder FXPreferredViewStyle -string 'Nlsv'
ok 'Finder default view set to list'
defaults write com.apple.finder FXDefaultSearchScope -string 'SCcf'
ok 'Finder search scope set to current folder'

# Dock
defaults write com.apple.dock show-recents -bool false
ok 'Dock recent apps disabled'
defaults write com.apple.dock tilesize -int 36
ok 'Dock icon size set to 36'

# Screenshots
mkdir -p "$HOME/screenshots"
defaults write com.apple.screencapture location "$HOME/screenshots"
ok 'Screenshot location set to ~/screenshots'
defaults write com.apple.screencapture disable-shadow -bool true
ok 'Screenshot drop shadow disabled'

# General
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
ok 'Default save location set to disk'
defaults write com.apple.screensaver askForPasswordDelay -int 0
ok 'Screensaver password delay set to 0'
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
ok '.DS_Store creation disabled on network and USB volumes'

# Printing
defaults write com.apple.print.PrintingPrefs 'Quit When Finished' -bool true
ok 'Printer app set to quit when finished'

# Apply changes
killall Finder
killall Dock
killall SystemUIServer
