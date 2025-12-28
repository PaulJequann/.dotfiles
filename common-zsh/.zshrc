# =============================================================================
# PATH Configuration (MUST BE FIRST)
# =============================================================================
# Essential PATH for device_configs tools (task, claude, bd, etc.)
export PATH="$HOME/.local/bin:$PATH"           # User binaries
export PATH="/usr/local/bin:$PATH"             # System-wide custom binaries

# Platform-specific PATH
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS: Homebrew paths
    export PATH="/opt/homebrew/bin:$PATH"      # Apple Silicon
    export PATH="/opt/homebrew/sbin:$PATH"
fi

# =============================================================================
# zgenom Plugin Manager
# =============================================================================
source "${HOME}/.zgenom/zgenom.zsh"

ZSH_DISABLE_COMPFIX=true

if ! zgenom saved; then
    zgenom ohmyzsh
    zgenom ohmyzsh plugins/history
    zgenom ohmyzsh plugins/git
    zgenom ohmyzsh plugins/dirhistory

    # Conditional Homebrew plugin (macOS only)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        zgenom ohmyzsh plugins/brew
    fi

    zgenom load zdharma/fast-syntax-highlighting
    zgenom load zsh-users/zsh-autosuggestions
    zgenom load spaceship-prompt/spaceship-prompt

    zgenom save
fi

# =============================================================================
# Modular Configuration
# =============================================================================
ZSHCONFIG="$HOME/.config/zsh"
[ -f "$ZSHCONFIG/core.zsh" ] && source "$ZSHCONFIG/core.zsh"
[ -f "$ZSHCONFIG/aliases.zsh" ] && source "$ZSHCONFIG/aliases.zsh"

# =============================================================================
# Platform-Specific Configuration
# =============================================================================
case "$(uname -s)" in
    Darwin)
        [ -f "$ZSHCONFIG/macos.zsh" ] && source "$ZSHCONFIG/macos.zsh"
        ;;
    Linux)
        if grep -qi microsoft /proc/version 2>/dev/null; then
            [ -f "$ZSHCONFIG/wsl.zsh" ] && source "$ZSHCONFIG/wsl.zsh"
        elif [ -f /etc/arch-release ]; then
            [ -f "$ZSHCONFIG/arch.zsh" ] && source "$ZSHCONFIG/arch.zsh"
        fi
        ;;
esac

# =============================================================================
# Common Keybindings
# =============================================================================
bindkey -s ^f "tmux-sessionizer\n"
