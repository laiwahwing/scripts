#!/bin/bash
# 2016-11-11

# Functions
function set_ps1(){
    local svr_id=$1
    local server_ver=$2
    if [ $UID -eq 0 ];then
        if [ ${#} -eq 0 ];then
            PS1="\[\033[34m\]\H: \[\033[33m\]\W \[\033[31m\]# \[\033[0m\]"
        else
            PS1="\[\033[34m\]$server_ver$svr_id: \[\033[33m\]\W \[\033[31m\]# \[\033[0m\]"
        fi
    else
        if [ ${#} -eq 0 ];then
            PS1="\[\033[34m\]\H: \[\033[33m\]\W \[\033[31m\]$ \[\033[0m\]"
        else
            PS1="\[\033[34m\]$server_ver$svr_id: \[\033[33m\]\W \[\033[31m\]\$ \[\033[0m\]"
        fi
    fi
}

function get_ip_location(){
    curl -s "http://ip-api.com/json/${1}"|jq
}

# run a command in the background
function bkr() {
    (nohup "$@" &>/dev/null &)
}

# rsync helpers:
function rsync_proxy(){
    dir=$1
    user=$2
    remote_host=$3
    remote_port=${4:22}
    rsync -avzPe 'ssh -p ${remote_port} -o "ProxyCommand nc -x 127.0.0.1:10180 %h %p"' $dir $user@$remote_host:/tmp/
}

# Make your man page colorful
export LESS_TERMCAP_mb=$'\E[1m\E[32m'
export LESS_TERMCAP_mh=$'\E[2m'
export LESS_TERMCAP_mr=$'\E[7m'
export LESS_TERMCAP_md=$'\E[1m\E[36m'
export LESS_TERMCAP_ZW=""
export LESS_TERMCAP_us=$'\E[4m\E[1m\E[37m'
export LESS_TERMCAP_me=$'\E(B\E[m'
export LESS_TERMCAP_ue=$'\E[24m\E(B\E[m'
export LESS_TERMCAP_ZO=""
export LESS_TERMCAP_ZN=""
export LESS_TERMCAP_se=$'\E[27m\E(B\E[m'
export LESS_TERMCAP_ZV=""
export LESS_TERMCAP_so=$'\E[1m\E[33m\E[44m'
# end
# Alias
shell=$(awk -F: '/'$USER'/{print $NF}' /etc/passwd 2>/dev/null)
# take effect only on bash
if [[ $shell == /bin/bash ]];then
    # quick back alias
    alias 1='cd -'
    alias 2='cd ../..;'
    alias 3='cd ../../..'
    alias ..='cd ..'
    alias ...='cd ../..'
    alias ....='cd ../../..'
    alias .....='cd ../../../..'
    alias ......='cd ../../../../..'
    alias _='sudo'
    # set history verify
    shopt -s histverify
    # Bind key up-arrow and down-arrow
    bind '"\e[A":history-search-backward'
    bind '"\e[B":history-search-forward'
fi
# common alias
alias d='dirs -v | head -10'
alias hip='hostname -I || hostname -i'
alias l='ls -CF'
alias la='ls -lAh'
alias ll='ls -lh'
alias lsa='ls -lah'
alias md='mkdir -p'
alias more='less'
alias nett='netstat -tunl'
alias netp='sudo netstat -tunlp'
alias tf='tail -f'
alias _ip='curl -s https://checkip.amazonaws.com'
alias _ipip='curl -s myip.ipip.net'
alias ports='sudo lsof -i -P'
alias po=popd
alias pu=pushd
alias pycmd='python -c'
alias pyj='python -m json.tool ${@} >/dev/null'
alias ps1='set_ps1'
alias rd=rmdir
alias rpwd="{ hostname -I|awk '{print \$NF}';pwd; } | awk '{printf \":\"\$NF}';echo"
alias ps_usage="ps -e -o pid,ppid,rss,vsz,uname,pmem,pcpu,comm --sort=-pcpu,-pmem|head -n 15"
alias net_count="netstat -a | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'"
# kubectl hepers:
alias kg="kubectl get"
alias kd="kubectl describe"
alias kgpan="kubectl get pod -o=custom-columns=NAME:.metadata.name,Namespace:.metadata.namespace,STATUS:.status.phase,NODE:.spec.nodeName,PodIP:.status.podIP --all-namespaces"
alias kgpo='kubectl get pod -o=custom-columns=NAME:.metadata.name,Namespace:.metadata.namespace,STATUS:.status.phase,NODE:.spec.nodeName,PodIP:.status.podIP'
alias kge='kubectl get events --sort-by=.metadata.creationTimestamp'
# docker helpers:
alias docker-rmi="docker rmi \$(docker image ls -q -f dangling=true)"
# Systemctl helpers:
alias sss='sudo systemctl status'
alias ssr='sudo systemctl restart'
alias ssstart='sudo systemctl start'
# Python helpers:
alias py=python
alias py3='source /data/venv/python3/bin/activate'
alias py2='source /data/venv/python2/bin/activate'
alias ogpy='source ~/.venv/origin/Scripts/activate'
alias pycmd='python -c'
alias pyclean='find . -name "*.pyc" -exec rm {} \;'
# MySql helpers: 
alias adminsql='sudo mysql --defaults-file=/data/admin/scripts/.pass.cnf'
# Ansible helpers:
alias ap='ansible-playbook '
alias apl='ansible-playbook --list-tasks --list-hosts '
