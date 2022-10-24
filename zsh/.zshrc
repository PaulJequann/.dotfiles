# load zgenom
source "${HOME}/.zgenom/zgenom.zsh"

ZSH_DISABLE_COMPFIX=true
# if the init script doesn't exist
if ! zgenom saved; then

  # specify plugins here
	zgenom ohmyzsh
	zgenom ohmyzsh plugins/history
	zgenom ohmyzsh plugins/git
	zgenom ohmyzsh plugins/dirhistory
	zgenom ohmyzsh plugins/brew

	zgenom load zdharma/fast-syntax-highlighting
	zgenom load zsh-users/zsh-autosuggestions

	zgenom load spaceship-prompt/spaceship-prompt


  # generate the init script from plugins above
 	 zgenom save
fi


export NVM_DIR="$HOME/.nvm"
source $(brew --prefix nvm)/nvm.sh
#[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
#[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


export PATH="/home/pj/.pyenv/bin:$PATH"
#eval "$(pyenv init -)"

if command -v pyenv &>/dev/null; then
    eval "$(pyenv init -)"
fi
if command -v pyenv-virtualenv &>/dev/null; then
    eval "$(pyenv virtualenv-init -)"
fi

bindkey -s ^f "tmux-sessionizer\n"

# Alias
alias vim='nvim'
alias ls='ls -la'

alias gam="/Users/pj/bin/gamadv-xtd3/gam"
