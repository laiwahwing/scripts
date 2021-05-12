#!/bin/bash
# author: cl
# date: 2016-11-2


function rsync_zsh(){
    remote_host=$1
    port=$2
    user=$3
    [ -z $port ] && port=22
    if [ -z $user ];then
        user=$USER
        home=$HOME
    else
        home=/home/$user
    fi
    if [ ! -z $remote_host ];then
        rsync -avze "ssh -p $port"  ~/.oh-my-zsh ~/.zshrc ~/.vimrc ~/.vim $user@$remote_host:$home/
    else
       echo "No Remote Host"
    fi
}

function rsync_ssh_config(){
    remote_host=$1
    port=$2
    [ -z $port ] && port=22
    if [ ! -z $remote_host ];then
        rsync -vtpze "ssh -p $port" ~/.ssh/config $USER@$remote_host:$HOME/.ssh/config
    else
        echo "No Remote Host"
    fi
}
# generate ssh-agent
env=~/.ssh/agent.env

agent_load_env () { test -f "$env" && . "$env" >| /dev/null ; }

agent_start () {
    (umask 077; ssh-agent >| "$env")
    . "$env" >| /dev/null ; }

agent_load_env

# agent_run_state: 0=agent running w/ key; 1=agent w/o key; 2= agent not running
agent_run_state=$(ssh-add -l >| /dev/null 2>&1; echo $?)

if [ ! "$SSH_AUTH_SOCK" ] || [ $agent_run_state = 2 ]; then
    agent_start
    ssh-add
elif [ "$SSH_AUTH_SOCK" ] && [ $agent_run_state = 1 ]; then
    ssh-add
fi

unset env
# something else
alias relsov_domain="while read a b;do echo -n \"$a \"; dig +short $a;done < dkdomain.txt "
alias rsync_proxy="rsync -avzPe 'ssh -p 27620 -o \"ProxyCommand nc -x 127.0.0.1:10180 %h %p\"'"
alias g='googler -n 7'
# pip zsh completion start
function _pip_completion {
  local words cword
  read -Ac words
  read -cn cword
  reply=( $( COMP_WORDS="$words[*]" \
             COMP_CWORD=$(( cword-1 )) \
             PIP_AUTO_COMPLETE=1 $words[1] ) )
}
compctl -K _pip_completion pip
# pip zsh completion end
