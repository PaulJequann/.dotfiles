# =============================================================================
# Arch Linux-Specific Configuration
# =============================================================================

# Flatpak XDG directories
export XDG_DATA_DIRS="/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share:$XDG_DATA_DIRS"

# Arch aliases
alias pacman='sudo pacman'
alias yay='yay --sudoloop'
