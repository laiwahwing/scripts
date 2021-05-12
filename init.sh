#!/bin/bash
# date: 2019-07-15

# make basic var
user=cl
tmpdir=/data/tmp
pyver=3.8.0
pydir=Python-${pyver}
app_path=/data/apps

# exit if user alread exists
if id $user;then
    exit
fi
# install python3 require soft
# install basic soft

release=$(cat /etc/os-release | awk -F[\"=] '/NAME/{print $3;exit}')
if [[ $release =~ 'CentOS' ]];then
    sudo sed -i -r '/^SELINUX=/s/=(.*)$/=disabled/' /etc/sysconfig/selinux
    sudo yum makecache
    sudo yum install -y -q deltarpm||sudo yum install -y drpm
    sudo yum install -y vim git zsh wget tmux readline-devel libzip-devel gdbm-devel ncurses-devel xz-devel libffi-devel zlib-devel libuuid-devel libsqlite3x-devel tk-devel bzip2-devel net-tools
    sudo yum install -y -q aria2 uuid-devel tkinter
else
    sudo apt update
    sudo apt install -y -q aria2 vim git zsh wget tmux libssl-dev libreadline-dev libzip-dev libgdbm-dev libncurses-dev liblzma-dev uuid-dev libffi-dev zlib1g-dev libbz2-dev libsqlite3-dev
fi

# create user
sudo groupadd -r pcats
# add sudoers group
sudo useradd -m -s /bin/zsh ${user}
sudo usermod -G pcats ${user}
# add sudo groups
if ! `sudo grep -q pcats /etc/sudoers`;then
    sudo sed -ri '$a\%pcats        ALL=(ALL)       NOPASSWD: ALL' /etc/sudoers
fi
# make temp dir
sudo mkdir -p ${tmpdir};sudo chown ${user}. ${tmpdir}
cd ${tmpdir}
echo "--- working on ${PWD} ---"
function deploy_py3(){
    yum install -y -q gcc
    echo "--- get python3 pack ---"
    if [ ! -d ${tmpdir}/${pydir} ];then
        wget "https://www.python.org/ftp/python/${pyver}/Python-${pyver}.tgz"
        sleep 3
        tar xf ${pydir}.tgz
    fi
    echo "--- install python3 ---"
    if [ ! -d ${app_path}/python ];then
        if [ -d ${tmpdir}/${pydir} ];then
            cd ${tmpdir}/${pydir}
            ./configure --prefix=${app_path}/python --exec-prefix=${app_path}/python -q
            sudo make -s
            sudo make -s install
        fi
        if [ -x ${app_path}/python/bin/python3 ];then
            sudo ${app_path}/python/bin/python3 -m venv /opt/venv/python3
            sudo chown ${user} /opt/venv/python3
        fi
    fi
}
# customize your home and path
export pre_home=/home/${user}
cd $pre_home
echo "--- install bash alias ---"
wget 'https://raw.githubusercontent.com/laiwahwing/scripts/master/.alias.sh' -O $pre_home/.alias.sh
echo "--- change shell to zsh ---"
echo "--- install oh-my-zsh ---"
wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O zsh_install.sh
sed -i '/exec/d' zsh_install.sh
sudo -u $user zsh zsh_install.sh --unattended
sleep 3
echo "--- get zsh config ---"
wget 'https://raw.githubusercontent.com/laiwahwing/scripts/master/.zprofile' -O $pre_home/.zprofile
wget 'https://raw.githubusercontent.com/laiwahwing/scripts/master/.zshrc' -O $pre_home/.zshrc
echo  "--- get zsh theme ---"
wget 'https://raw.githubusercontent.com/laiwahwing/scripts/master/wedisagree-mod.zsh-theme' -O $pre_home/.oh-my-zsh/themes/wedisagree-mod.zsh-theme
echo "--- install vim fisa-vim"
wget "https://raw.githubusercontent.com/laiwahwing/scripts/master/.vimrc" -O $pre_home/.vimrc 
echo "--- done enjoy it ---"
### Add cl key to cl account
mkdir -m 700 .ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6cGft/WqAbdxFG6XSrgUB83uh2cbNCj45w9e+0q8tBYKeH5P/SbirqVRenttfrW7qjVZQXtXQ3V1jgYj0Vtl3rOcDL5SZ/4xJfw2G9KPJY7bysh+nuuTqWPCluAkwzYIcp84zgEJ20pw0VwM3AHB2xwqz4nKcPloJ+zaZAXaeshS4fHpzBOJlJY/lv844k8oYjnZSBjhSa0yiQ3K/ITBenB4gkKiOmXVoSZloYvsOcmeARXUvFtY0Va0FXXbkA1OklQvMLmd0hebRV3MiZZWndOMCNwjvdyg8SgdBB6zu8lEMRmnPOmpSBaj93wwacUR1FbL9v6pyY4jleyKKX3iBw== cl" |tee -a $pre_home/.ssh/authorized_keys
chmod 600 $pre_home/.ssh/authorized_keys
echo "#!/bin/bash

count=\$(ps -ef|awk -v u=\$USER '/tmux|sshd/{if(\$1==u && \$0!~\"awk\")print}'|grep -c \$USER)
pid=\$(pgrep -u \$USER ssh-agent)
if [[ \$count -le 1 ]] && [[ ! -z \${pid} ]];then
    pkill -u \${USER} ssh-agent
fi" |tee -a $pre_home/.zlogout |tee -a $pre_home/.bash_logout
chown ${user}. -R $pre_home
#
