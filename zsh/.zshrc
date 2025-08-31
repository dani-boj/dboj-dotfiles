# Enable Powerlevel9k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p9k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p9k-instant-prompt-${(%):-%n}.zsh"
# fi

# POWERLEVEL8K_INSTANT_PROMPT=off

# POWERLEVEL8K_INSTANT_PROMPT=quiet

# Load completions
autoload -Uz compinit && compinit

# Plugin manager: zinit
# Set the directory for zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit if it doesn't exist
if [[ ! -d $ZINIT_HOME ]]; then
	mkdir -p "$(dirname "$ZINIT_HOME")"
	git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Zinit plugins
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light zdharma/fast-syntax-highlighting

zinit light zsh-users/zsh-completions

zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::ssh
zinit snippet OMZP::kubectl
zinit snippet OMZP::helm
zinit snippet OMZP::sudo
zinit snippet OMZP::aws
zinit snippet OMZP::docker
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# Replay old cached completions
zinit cdreplay -q

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

export PATH=$PATH:/home/dboj/.local/bin
export $(envsubst < /home/dboj/.config/.env)

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="powerlevel10k/powerlevel10k"
# ZSH_THEME="spaceship"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# plugins=(
# 		git
# 		zsh-autosuggestions
# 		zsh-syntax-highlighting
# )


# source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# MPD Socket
export MPD_HOST=/home/dboj/.config/mpd/socket

# Custom alias
alias zshconfig="nvim ~/.zshrc"
alias la="ls -la"
alias cd="z"
alias vim-s="nvim --listen /tmp/nvimsocket"

# Execute VPN connection script
alias wdon="sudo pon wdreams && sleep 3 && sudo ip route add default via 172.16.0.100 dev ppp0"
alias wdoff="sudo poff wdreams"

# Pacman update and cleaning
alias pacup="sudo pacman -Syu --noconfirm && sudo pacman -Sc --noconfirm && sudo pacman -Scc --noconfirm"
alias yayup="yay -Syu --noconfirm && yay -Sc --noconfirm && yay -Scc --noconfirm"

# Mount units whhen at office VPN
alias mnt-ryc="sudo mount -aT /home/dboj/Network/mount_tabs/sistemas"

# Warp-Cli Modes
alias warp="warp-cli mode warp+doh"
alias doh="warp-cli mode doh"

# Custom PATHs
# Kanata in Cargo 
export PATH=$PATH:/usr/bin/kanata
# Android Paths
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
# Java Paths
export JAVA_HOME=/usr/lib/jvm/jre-23-openjdk/
export PATH=$PATH:$JAVA_HOME/bin
# Tmuxifier
export PATH="$HOME/.tmuxifier/bin:$PATH"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
# source /home/dboj/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# History
HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups
setopt hist_reduce_blanks

# Completition styling
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls $realpath'

# Starship
prompt off
eval "$(starship init zsh)"
export STARSHIP_CONFIG=~/.config/starship/starship.toml
source ~/starship-prompt.zsh

# Shell Integrations
# FZF
eval "$(fzf --zsh)"

#ZOxide
eval "$(zoxide init zsh)"

# The Fuck -> Command auto correction with alias fck
eval "$(thefuck -a fk)"

# Tmuxifier
eval "$(tmuxifier init -)"

# Pipx
export PATH=$PATH:/usr/bin/pipx
eval "$(register-python-argcomplete pipx)"

# Jupyter pipx installation
export PATH=$PATH:/home/dboj/.local/share/pipx/venvs/notebook/bin

# NVM for managing node versions
# source /usr/share/nvm/init-nvm.sh

# Welcome message
fastfetch
echo "Welcome to the Matrix, Neo!"

# Tmux initializer
/home/dboj/workspace/bash-scripts/init-tmux.sh

# SSH-Agent init: REVISAR EN CADA HOST NUEVO
echo "Recharging SSH Keys:"
#[ -z "$SSH_AUTH_SOCK" ] && eval "$(ssh-agent -s)" > /dev/null
if [ ! -S ~/.ssh/ssh_auth_sock ]; then
  eval `ssh-agent` > /dev/null
  ln -sf "$SSH_AUTH_SOCK" ~/.ssh/ssh_auth_sock
fi

export SSH_AUTH_SOCK=~/.ssh/ssh_auth_sock
ssh-add -l > /dev/null || {
  ssh-add /home/dboj/.ssh/id_ansible 
  ssh-add /home/dboj/.ssh/id_ed25519
}
