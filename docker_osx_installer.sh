#!/bin/bash

# Console colors
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[1;33m'
NC='\033[0m'

# Make sure OS is OSX
if [ $(uname) != "Darwin" ]; then
    echo -e "${red}This script can only be run from OSX!${NC}"
    exit 1
fi

# Print usage if no parameters are set
if [ $# -lt 1 ]; then
    echo -e "Usage: docker_osx_installer.sh [OPTIONS] COMMAND [arg...]"
    echo -e "Commands:"
    echo -e "    install \tInstall all required packages (brew, brew-cask, virtualbox, vagrant, docker, docker-compose)"
    echo -e "    uninstall \tUninstall all required packages"
    echo -e "    create-boot2docker \tCreate a boot2docker vm with NFS sharing"
    echo -e "    forward-ports-boot2docker \tCreate boot2docker network port forwards"
    echo -e "    delete-boot2docker \tDelete the boot2docker-vm Virutal Machine"
    exit 1
fi

if [ $1 = 'create-boot2docker' ]; then 
    echo -e "${green}Downloading boot2docker ISO (version 1.7.0)...${NC}"
    boot2docker --iso-url=https://github.com/boot2docker/boot2docker/releases/download/v1.7.0/boot2docker.iso download
    # Start the boot2docker VM
    echo -e "${green}Starting the boot2docker VM...${NC}"
    boot2docker init
    boot2docker up

    SOURCE_FILE='';
    # Detect shell to write to the right .rc file
    if [[ $SHELL == '/bin/bash' || $SHELL == '/bin/sh' ]]; then SOURCE_FILE=".bashrc"; fi
    if [[ $SHELL == '/bin/zsh' ]]; then SOURCE_FILE=".zshrc"; fi

    if [[ $SOURCE_FILE ]]; then
        # See if we already did this and skip if so
        grep -q "export DOCKER_HOST=tcp://192.168.59.103:2375" $HOME/$SOURCE_FILE
        if [[ $? -ne 0 ]]; then
            echo -e "${green}Adding automatic DOCKER_HOST export to $HOME/$SOURCE_FILE${NC}"
            echo -e "# boot2docker env" >> $HOME/$SOURCE_FILE
            echo -e "export DOCKER_HOST=tcp://192.168.59.103:2375" >> $HOME/$SOURCE_FILE
            echo -e "export DOCKER_TLS_VERIFY=1" >> $HOME/$SOURCE_FILE
            echo -e "export DOCKER_CERT_PATH=$HOME/.boot2docker/certs/boot2docker-vm" >> $HOME/$SOURCE_FILE
        fi
    else
        echo -e "${red}Cannot detect your shell. Please manually add the following to your respective .rc or .profile file:${NC}"
        echo -e "$DOCKER_HOST_EXPORT"
    fi


    # needed as workaround for issue: https://github.com/boot2docker/boot2docker/issues/824#issuecomment-113904164
    echo -e "${green}Applying boot2docker vm fix for issue https://github.com/boot2docker/boot2docker/issues/824...${NC}"
    boot2docker ssh "echo -e 'wait4eth1() {\nCNT=0\nuntil ip a show eth1 | grep -q UP\n do\n[ $((CNT++)) -gt 60 ] && break || sleep 1\ndone\nsleep 1\n}\nwait4eth1' | sudo tee /var/lib/boot2docker/profile"
    boot2docker restart

    # Networking, use DHCP, but always use IP 192.168.59.103
    [ -f $HOME/.boot2docker/profile ] || boot2docker config|sed 's/LowerIP.*/LowerIP \= \"192\.168\.59\.103\"/'|sed 's/UpperIP.*/UpperIP \= \"192\.168\.59\.103\"/' > $HOME/.boot2docker/profile

    # File Sharing: disable vbox-share
    echo -e "${green}Reconfiguring boot2docker file sharing...${NC}"
    boot2docker stop 
    VBoxManage sharedfolder remove boot2docker-vm --name Users
    boot2docker start --vbox-share=disable

    # Source the file so we can use the DOCKER_HOST variabel right away.
    source $HOME/$SOURCE_FILE

    # Enable NFS shares
    echo -e "${green}Configuring local NFS sharing...${NC}"
    sudo touch /etc/exports
    echo -e "# Boot2docker \n\"$HOME\" -alldirs -mapall=$(whoami) -network 192.168.59.0 -mask 255.255.255.0" | sudo tee -a /etc/exports
    sudo nfsd checkexports && sudo nfsd restart

    # Add NFS mounts to boot2docker startup
    echo -e "${green}Configuring boot2docker NFS mounts...${NC}"
    boot2docker ssh "echo -e '#\0041/bin/sh' | sudo tee /var/lib/boot2docker/bootlocal.sh && sudo chmod 755 /var/lib/boot2docker/bootlocal.sh"
    boot2docker ssh "echo 'sudo mkdir -p $HOME && sudo mount -t nfs -o noatime,soft,nolock,vers=3,udp,proto=udp,rsize=8192,wsize=8192,namlen=255,timeo=10,retrans=3,nfsvers=3 -v 192.168.59.3:$HOME $HOME' | sudo tee -a /var/lib/boot2docker/bootlocal.sh"
    boot2docker restart --vbox-share=disable
    boot2docker ssh mount

    echo -e "${green}boot2docker is not running with NFS sharing${NC}"
fi

if [ $1 = "forward-ports-boot2docker" ]; then
    echo -e "${green}Adding common port forwarding rules to boot2docker vm...${NC}"
    boot2docker stop 
    VBoxManage modifyvm "boot2docker-vm" --natpf1 "http,tcp,127.0.0.1,80,,80"
    VBoxManage modifyvm "boot2docker-vm" --natpf1 "https,tcp,127.0.0.1,443,,443"
    VBoxManage modifyvm "boot2docker-vm" --natpf1 "flask,tcp,127.0.0.1,5000,,5000"
    VBoxManage modifyvm "boot2docker-vm" --natpf1 "websocket,tcp,127.0.0.1,5100,,5100"
    VBoxManage modifyvm "boot2docker-vm" --natpf1 "superdeskapi,tcp,127.0.0.1,5050,,5050"
    VBoxManage modifyvm "boot2docker-vm" --natpf1 "redis,tcp,127.0.0.1,6379,,6379"
    VBoxManage modifyvm "boot2docker-vm" --natpf1 "mysql,tcp,127.0.0.1,3306,,3306"
    VBoxManage modifyvm "boot2docker-vm" --natpf1 "mongo,tcp,127.0.0.1,27017,,27017"
    VBoxManage modifyvm "boot2docker-vm" --natpf1 "superdesk,tcp,127.0.0.1,9000,,9000"
    VBoxManage modifyvm "boot2docker-vm" --natpf1 "elastic,tcp,127.0.0.1,9200,,9200"
    boot2docker start --vbox-share=disable
fi

# delete current boot2docker vm
if [ $1 = "delete-boot2docker" ]; then
    echo -e "${red}This will delete your current boot2docker vm completely${NC}"
    read -r -p "Are you sure? [y/N] " response
    case $response in
        [yY][eE][sS]|[yY]) 
            boot2docker poweroff
            boot2docker delete
            # additional virtualbox cleanup
            rm -rf "$HOME/VirtualBox VMs/boot2docker-vm"
            # remove boot2docker user config
            rm -rf $HOME/.boot2docker
            # TODO: cleanup .bashrc 
            SOURCE_FILE='';
            # Detect shell to write to the right .rc file
            if [[ $SHELL == '/bin/bash' || $SHELL == '/bin/sh' ]]; then SOURCE_FILE=".bashrc"; fi
            if [[ $SHELL == '/bin/zsh' ]]; then SOURCE_FILE=".zshrc"; fi
            cat $HOME/$SOURCE_FILE|grep -v DOCKER|grep -v boot2docker > $HOME/$SOURCE_FILE 
            
            # cleanup /etx/exports
            echo -e "${red}Removing boot2docker NFS share from exports...${NC}"
            sudo cat /etc/exports|grep -v "\"$HOME\" -alldirs -mapall=$(whoami) -network 192.168.59.0 -mask 255.255.255.0"|grep -v "Boot2docker" | sudo tee /etc/exports
            sudo nfsd checkexports && sudo nfsd restart  
            ;;
        *)
            echo -e "${green}Exiting without uninstalling...${NC}"
            ;;
    esac
    exit 1
fi

# Do full uninstall
if [ $1 = "uninstall" ]; then
    echo -e "${red}Uninstall will remove existing packages, and boot2docker vm completely${NC}"
    echo -e "The following packages will be deleted:"
    echo -e "    virtualbox"
    echo -e "    vagrant"
    echo -e "    docker"
    echo -e "    docker-compose"
    echo -e "    boot2docker"
    read -r -p "Are you sure? [y/N] " response
    case $response in
        [yY][eE][sS]|[yY]) 
            echo -e "${red}Uninstalling virtualbox...${NC}"
            # first turn off the boot2docker-vm
            VBoxManage controlvm boot2docker-vm poweroff
            # now kill all VBox processes 
            $(ps aux|grep VBox|grep -v grep|awk '{print "kill -9 "$2}')
            brew cask uninstall virtualbox
            echo -e "${red}Uninstalling vagrant...${NC}"
            brew cask uninstall vagrant
            echo -e "${red}Uninstalling docker...${NC}"
            brew uninstall docker
            echo -e "${red}Uninstalling docker-compose...${NC}"
            brew uninstall docker-compose
            echo -e "${red}Uninstalling boot2docker...${NC}"
            brew uninstall boot2docker

            # remove boot2docker user config
            rm -rf $HOME/.boot2docker

            # additional virtualbox cleanup
            rm -rf "$HOME/VirtualBox VMs"
            rm -rf $HOME/Library/VirtualBox
            rm -rf $HOME/Library/Saved Application State/org.virtualbox.app.VirtualBox*

            # cleanup .rc 
            SOURCE_FILE='';
            # Detect shell to write to the right .rc file
            if [[ $SHELL == '/bin/bash' || $SHELL == '/bin/sh' ]]; then SOURCE_FILE=".bashrc"; fi
            if [[ $SHELL == '/bin/zsh' ]]; then SOURCE_FILE=".zshrc"; fi
            cat $HOME/$SOURCE_FILE|grep -v DOCKER|grep -v boot2docker > $HOME/$SOURCE_FILE 
            
            # cleanup /etc/exports
            echo -e "${red}Removing boot2docker NFS share from exports...${NC}"
            cat /etc/exports|grep -v "\"$HOME\" -alldirs -mapall=$(whoami) -network 192.168.59.0 -mask 255.255.255.0"|grep -v "Boot2docker" | sudo tee /etc/exports
            sudo nfsd checkexports && sudo nfsd restart  
            ;;
        *)
            echo -e "${green}Exiting without uninstalling...${NC}"
            ;;
    esac
    exit 1
fi

# Do full install
if [ $1 = "install" ]; then
    #
    # Check if Homebrew is installed
    #
    which -s brew
    if [[ $? != 0 ]] ; then
        # Homebrew installation
        echo -e "${green}Installing Homebrew...${NC}"
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    else
        echo -e "${green}Homebrew already installed...${NC}"
        # Update brew formulae
        echo -e "${green}Updating brew formulae...${NC}"
        brew update
    fi

    #
    # Check if Cask is installed
    #
    which -s brew-cask
    if [[ $? != 0 ]] ; then
        # Cask installation
        echo -e "${green}Installing Cask...${NC}"
        brew install caskroom/cask/brew-cask
    else
        echo -e "${green}Cask already installed...${NC}"
    fi

    #
    # Check if virtualbox is installed
    #
    which -s virtualbox
    if [[ $? != 0 ]] ; then
        # VirtualBox installation
        echo -e "${green}Installing virtualbox...${NC}"
        brew cask install virtualbox
    else
        echo -e "${green}virtualbox already installed...${NC}"
    fi

    #
    # Check if vagrant is installed
    #
    which -s vagrant
    if [[ $? != 0 ]] ; then
        # Vagrant installation
        echo -e "${green}Installing vagrant...${NC}"
        brew cask install vagrant
    else
        echo -e "${green}vagrant already installed...${NC}"
    fi

    #
    # Check if docker is installed
    #
    which -s docker
    if [[ $? != 0 ]] ; then
        # Install docker
        echo -e "${green}Installing docker...${NC}"
        brew install docker
    else
        echo -e "${green}docker already installed...${NC}"
    fi

    #
    # Check if docker-compose is installed
    #
    which -s docker-compose
    if [[ $? != 0 ]] ; then
        # Install docker-compose
        echo -e "${green}Installing docker-compose...${NC}"
        brew install docker-compose
    else
        echo -e "${green}docker-compose already installed...${NC}"
    fi

fi


