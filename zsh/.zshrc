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
#source $(brew --prefix nvm)/nvm.sh
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

export SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt

export XDG_DATA_DIRS="/var/lib/flatpak/exports/share:/home/pj/.local/share/flatpak/exports/share:$XDG_DATA_DIRS"
# export SSH_AGENT_SOCK=$SSH_AUTH_SOCK

if [ -z "$SSH_AUTH_SOCK" ]; then
   # Check for a currently running instance of the agent
   RUNNING_AGENT="`ps -ax | grep 'ssh-agent -s' | grep -v grep | wc -l | tr -d '[:space:]'`"
   if [ "$RUNNING_AGENT" = "0" ]; then
        # Launch a new instance of the agent
        ssh-agent -s &> $HOME/.ssh/ssh-agent
   fi
   eval `cat $HOME/.ssh/ssh-agent` > /dev/null
   ssh-add 2> /dev/null
fi
