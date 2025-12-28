# =============================================================================
# NVM (Node Version Manager)
# =============================================================================
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # nvm bash completion

# =============================================================================
# Pyenv (Python Version Manager)
# =============================================================================
export PATH="$HOME/.pyenv/bin:$PATH"  # Add pyenv to PATH

# Initialize pyenv if available
if command -v pyenv &>/dev/null; then
    eval "$(pyenv init -)"
fi

# Initialize pyenv-virtualenv if available
if command -v pyenv-virtualenv &>/dev/null; then
    eval "$(pyenv virtualenv-init -)"
fi
