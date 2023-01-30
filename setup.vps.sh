#!/bin/sh

CURRENT_USER=$(whoami)

#* For Colored Logs
cp() {
  case "$1" in
    "red")
      printf "\033[1;31m$2\033[0m\n"
      ;;
    "green")
      printf "\033[1;32m$2\033[0m\n"
      ;;
    "yellow")
      printf "\033[1;33m$2\033[0m\n"
      ;;
    "orange")
      printf "\033[1;34m$2\033[0m\n"
      ;;
    "purple")
      printf "\033[1;35m$2\033[0m\n"
      ;;
    "cyan")
      printf "\033[1;36m$2\033[0m\n"
      ;;
    "gray" | "grey")
      printf "\033[1;37m$2\033[0m\n"
      ;;
    "white")
      printf "\033[1;37m$2\033[0m\n"
      ;;
    *)
      printf "$2\n"
      ;;
  esac
}

create_new_user(){
  cp cyan "Enter name for new user"
  read _newusername
  CURRENT_USER=$_newusername
  sudo adduser $_newusername && cp green "User $_newusername created successfully" || cp red "Something went wrong. User $_newusername not created" 
  echo "\n"
}

change_user_password(){
  cp cyan "Enter username for user you want to change password"
  read _changePassForUser
  sudo passwd $_changePassForUser && cp green "Password for $_changePassForUser changed successfully" || cp red "Something went wrong. Password for user $_changePassForUser may not have changed" 
  echo "\n"
}

delete_user(){
    cp red "Proceed with caution. This action can not be cancel or can be reverted"
    cp red "This action will delete user and also delete user home directory and mail spool"
    cp cyan "Enter user you want to delete"
    read _delUsername
    cp red "killing all user's running processes" && \
    sudo killall -u $_delUsername && \
    cp red "removing user's home directory and mail spool" && \
    userdel -r $_delUsername && \
    cp green "User $_delUsername deleted successfully" || \
    cp red "Something went wrong. $_delUsername might not have deleted and may not work properly" 
    echo "\n"
}

install_prerequisite(){
  cp cyan "Installing Prerequisite Packages"
  # curl – transfers data
  # software-properties-common – adds scripts to manage the software
  # ca-certificates – lets the web browser and system check security certificates
  # apt-transport-https – lets the package manager transfer files and data over https
  sudo apt-get install -y curl software-properties-common ca-certificates apt-transport-https git neovim && \
  cp green "Successfully installed Prerequisite Packages" || \
  cp red "Something went wrong Prerequisite Packages might not have installed properly"
  echo "\n"
}

update_system(){
  cp cyan "Updating system"
  sudo apt-get update -y
  sudo apt-get upgrade -y && \
  cp green "System updated sucessfully"
  echo "\n"
}

add_user_to_group(){
  cp cyan "Show all users (press: a)"
  cp cyan "Show system created users (press: s)"
  cp cyan "Show human  created users (press: h)"
  read _showUsers
  if [ "$_showUsers" = "A" ] || [ "$_showUsers" = "a" ]; then
    cp gray "showing all users,  seperated by comma(,)"
    getent passwd | cut -d: -f1 | tr '\n' ','
  elif [ "$_showUsers" = "S" ] || [ "$_showUsers" = "s" ]; then
    cp gray "showing all system users,  seperated by comma(,)"
    getent passwd | awk -F: '$3 < 1000 {print $1}' | tr '\n' ','
  elif [ "$_showUsers" = "H" ] || [ "$_showUsers" = "h" ]; then
    cp gray "showing all human users, seperated by comma(,)"
    getent passwd | awk -F: '$3 >=1000 {print $1}' | tr '\n' ','
  fi

  echo "\n"
  cp cyan "Show available groups on system ? (y/n)"
  read _showgrps
  if [ "$_showgrps" = "A" ] || [ "$_showgrps" = "a" ]; then
    cp cyan "Showing available groups on system, seperated by comma(,)"
    cut -d: -f1 /etc/group | tr '\n' ','
  fi

  echo "\n"
  cp cyan "Enter group you want to add user to"
  read _addToGroup

  cp cyan "Enter user you want to add group $_addToGroup"
  read _userToAdd
  
  echo "\n"
  cp cyan "Adding $_userToAdd to group $_addToGroup"
  sudo usermod -aG $_addToGroup $_userToAdd && \
  cp green "User $_userToAdd added successfully to group $_addToGroup" || 
  cp red "Something went wrong. $_userToAdd might not have been added to group $_addToGroup" 
  echo "\n"
}

install_docker(){
  cp cyan "Adding the Docker Repositories"
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  sudo apt update -y
  # Make sure you are installing from the Docker repo instead of the default Ubuntu repo with this command
  apt-cache policy docker-ce
  # output will look like the following with different version numbers
  # docker-ce:
  #    Installed: (none)
  #    Candidate: 16.04.1~ce~4-0~ubuntu
  #    Version table:
  #        16.04.1~ce~4-0~ubuntu 500
  #             500 https://download.docker.com/linux/ubuntubionic/stableamd64packages
  cp cyan "Installing Docker"
  sudo apt install docker-ce -y
  # Enable Docker service on system startup
  cp green "It is recommended to start docker service on system startup"
  cp cyan "Enable docker service on system startup ? (y/n)"
  read docker_on_start
  if [ "$docker_on_start" = "y" ] || [ "$docker_on_start" = "Y" ]; then
    cp cyan "Enabling Docker service for system startup"
    sudo systemctl enable --now docker && cp green "Docker service will be started on system startup"
  fi
  
  cp cyan "Add current user $(CURRENT_USER) to Docker group to use docker without sudo ? (y/n)"
  read docker_without_sudo
  if [ "$docker_without_sudo" = "y" ] || [ "$docker_without_sudo" = "Y" ]; then
    cp cyan "Adding $(CURRENT_USER) to Docker for using docker commands without sudo"
    sudo usermod -aG docker $(CURRENT_USER)
  fi

  cp green "Docker successfully installed and configured."
  echo "\n"
}

install_portainer(){
  cp cyan "Change poratiner volume name ? (y/n) (default: portainer_data)"
  poratiner_vol_name="portainer_data"
  read _changePn
  if [ "$_changePn" = "y" ] || [ "$_changePn" = "Y" ]; then
    poratiner_vol_name=$_changePn
  fi
  docker --version && \
  docker volume create $poratiner_vol_name && \
  docker run -d \
  -p 9444:8000 -p 9443:9443 \
  --name portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $poratiner_vol_name:/data portainer/portainer-ce:latest && \
  cp green "Portainer is running on port: 9443"
  echo "\n"
}


setup_fresh_install(){
  #! 0. Setup Automatic/Manual
  cp green "Setup For Fresh Install Automatically or Manually(a/m)"
  read _auto_manual
  if [ "$_auto_manual" = "A" ] || [ "$_auto_manual" = "a" ]; then
      update_system
      install_prerequisite
      cp red "Recommended to create new user and avoid use of root user"
      create_new_user
      install_docker
      install_portainer
  elif [ "$_auto_manual" = "M" ] || [ "$_auto_manual" = "m" ]; then

      #? 1. Update System
      cp cyan "Update System ? (y/n)"
      read _update_system
      if [ "$_update_system" = "Y" ] || [ "$_update_system" = "y" ]; then
          update_system
      fi

      #? 2. Install Prerequisite Packages
      cp cyan "Install Prerequisite Packages ? (y/n)"
      read _installPrereq
      if [ "$_installPrereq" = "Y" ] || [ "$_installPrereq" = "y" ]; then
          install_prerequisite
      fi
      
      #? 3. Setup Docker
      cp cyan "Install and configure Docker ? (y/n)"
      read _setupDocker
      if [ "$_setupDocker" = "Y" ] || [ "$_setupDocker" = "y" ]; then
        install_docker
      fi
  fi
  echo "\n"
}

while true; do
  echo "\n\n"
  cp red "This script is only for ubuntu based systems."
  cp red "Running in systems other than ubuntu may or may not work properly";
  cp orange "press: 0 for : Setup freshly installed system"
  cp orange "press: 1 for : Update system"
  cp orange "press: 2 for : Install prerequisite packages (curl git nano neovim ...)"
  cp orange "press: 3 for : Create new user"
  cp orange "press: 4 for : Change user password"
  cp orange "press: 5 for : Delete existing user"
  cp orange "press: 6 for : Add user to group"
  cp orange "press: 7 for : Install and configure Docker (for running containerized applications)"
  cp orange "press: 8 for : Install Portainer (Web interface for managing Docker)"
  cp cyan   "press: 9 for : Exit Script"
  echo "\n"
  cp green "What you want to do ? (options: 0-8)"
  read _action
  case "$_action" in
    "0") setup_fresh_install ;;
    "1") update_system ;;
    "2") install_prerequisite ;;
    "3") create_new_user ;;
    "4") change_user_password ;;
    "5") delete_user ;;
    "6") add_user_to_group ;;
    "7") install_docker ;;
    "8") install_portainer ;;
    "9") cp green "Exiting script"; exit 0 ;;
    *) cp red "invalid option"; echo "\n" ;;
  esac
done
