#!/bin/zsh
# Created by newuser for 5.1.1

autoload -Uz colors
colors

# lscolors
eval `dircolors ~/.colorrc`
alias ls='ls -F --color=auto'

# --Directories--
setopt auto_cd

# --Completion--
autoload -Uz compinit
compinit

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' ignore-parents parent pwd ..
zstyle ':completion:*:processes' command 'ps x -o pid,s,args'

setopt auto_param_slash
setopt list_packed

# --Expansion--
setopt case_glob
setopt glob_dots
setopt mark_dirs
setopt warn_create_global

# --History--
HISTFILE=${ZDOTDIR}/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt hist_find_no_dups
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_save_by_copy
setopt share_history

# --Input/Output--
setopt ignore_eof

# --Prompting--
autoload -Uz vcs_info
autoload -Uz add-zsh-hook

prompt_left=""
prompt_header=""
RPROMPT=""

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' formats "${fg[green]}(%s)-[%b]${fg[default]}"
zstyle ':vcs_info:*' actionformats "${#fg[red]}(%s)-[%b|%a]${#fg[default]}"

zstyle ':vcs_info:*+set-message:*' hooks vcs_info_hook
zstyle ':vcs_info:*+no-vcs:*' hooks no_vcs_hook

novcs_color_len=$((${#fg[yellow]} + ${#fg[default]}))
noaction_color_len=$((${novcs_color_len} + ${#fg[green]} + ${#fg[default]}))
action_color_len=$((${novcs_color_len} + ${#fg[red]} + ${#fg[default]}))

function +vi-vcs_info_hook() {
  if [ -z ${hook_com[action]} ]; then
    prompt_color_len=$noaction_color_len
  else
    prompt_color_len=$action_color_len
  fi
}

function +vi-no_vcs_hook() {
  prompt_color_len=$novcs_color_len
}

function generate_promopt_header() {
  prompt_header=$(printf "\n%s%*s" "$prompt_left" \
    "$((${COLUMNS}-${#prompt_left}+${prompt_color_len}+${prompt_left_color_len}-1))" \
    "${vcs_info_msg_0_}")
  PROMPT="${prompt_header}
%B%(?,%F{green},%F{red})%(!,#,$)%f%b "
}

function _update_vcs_info_msg() {
  LANG=en_US.UTF-8 vcs_info
  prompt_left="${fg[yellow]}[${USER}@${HOST}]${fg[default]} ${PWD/$HOME/"~"}"
  generate_promopt_header
#  RPROMPT="${vcs_info_msg_0_}"
}
add-zsh-hook precmd _update_vcs_info_msg

TRAPWINCH() {
  generate_promopt_header
  zle .reset-prompt
}

#PROMPT="%{${fg[red]}%}[%n@%m]%{${reset_color}%} %~
#%B%(?,%F{green},%F{red})%(!,#,$)%f%b "

# --Others--
setopt print_eight_bit
setopt no_beep
unsetopt promptcr

# --Aliases--
alias la='ls -A'
alias ll='ls -l'
alias lal='ls -Al'

# --Envilonment Variables--
export VIMCOLOR='molokai'
export XDG_CONFIG_HOME="$HOME/.config"

source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# --Enable ssh-agent --
SSH_ENV=$HOME/.ssh/environment

function start_agent {
  ssh-agent > $SSH_ENV
  chmod 600 $SSH_ENV
  . $SSH_ENV > /dev/null
  ssh-add
}

if [ -f $SSH_ENV ]; then
  . $SSH_ENV > /dev/null
  if ps ${SSH_AGENT_PID:-999999} | grep ssh-agent$ > /dev/null &&
     test -S $SSH_AUTH_SOCK; then
    # agent already running
  else
    start_agent;
  fi
else
  start_agent
fi

#eval `ssh-agent`

if [ $SHLVL = 1 ] ; then
  tmux
fi
