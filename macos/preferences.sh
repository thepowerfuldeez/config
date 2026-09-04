#!/usr/bin/env bash
# Explicitly saved preferences from the source Mac, 2026-09-04.
# Run manually on a new Mac; log out/in for all changes to take effect.
set -euo pipefail
defaults write NSGlobalDomain AppleInterfaceStyle -string Dark
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write com.apple.finder FXPreferredViewStyle -string Nlsv
defaults write com.apple.dock tilesize -int 40
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool false
