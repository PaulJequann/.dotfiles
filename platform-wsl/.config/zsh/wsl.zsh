# =============================================================================
# WSL2-Specific Configuration
# =============================================================================

# SSH agent management
if [ -z "$SSH_AUTH_SOCK" ]; then
    RUNNING_AGENT="$(ps -ax | grep 'ssh-agent -s' | grep -v grep | wc -l | tr -d '[:space:]')"
    if [ "$RUNNING_AGENT" = "0" ]; then
        ssh-agent -s &> "$HOME/.ssh/ssh-agent"
    fi
    eval "$(cat "$HOME/.ssh/ssh-agent")" > /dev/null
    ssh-add 2> /dev/null
fi

# WSL-specific paths
export PATH="$PATH:/mnt/c/Windows/System32"

# GAM7 (Google Workspace Admin)
# Override oh-my-zsh git plugin's 'gam' alias (git am)
unalias gam 2>/dev/null
export PATH="$HOME/bin/gam7:$PATH"

export WINDOWS_HOST_IP=$(ip route | grep default | awk '{print $3}')
export LOCAL_OLLAMA_URL="http://${WINDOWS_HOST_IP}:11434/v1"