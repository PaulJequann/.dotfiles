# =============================================================================
# macOS-Specific Configuration
# =============================================================================

# Homebrew environment (PATH already set in main .zshrc)
if command -v brew &>/dev/null; then
    export HOMEBREW_NO_AUTO_UPDATE=1
fi

# GAM (Google Workspace Admin tool)
alias gam="$HOME/bin/gamadv-xtd3/gam"
