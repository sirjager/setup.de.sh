#!/bin/bash

applyDotFiles() {
  git clone --bare https://github.com/sirjager/.dots "$HOME/.dots"
  if ! git --git-dir="$HOME/.dots" --work-tree="$HOME" checkout; then
    echo "Error: git checkout failed"
    exit 1
  fi
  git --git-dir="$HOME/.dots" --work-tree="$HOME" config --local status.showUntrackedFiles no
}

install_packages() {
  sudo pacman -S \
  python-pip neofetch nautilus neovim kitty plank \
  xclip light mpv feh \
  -y --needed
}

build_aur_packages() {
  pamac build timeshift \
  extension-manager \
  visual-studio-code-bin google-chrome brave-bin \
  ulauncher \
  --no-confirm
}

setup_window_manager_bspwm() {
  sudo pacman -S \
  yad feh rofi light xclip dunst sxhkd \
  polybar xdotool python-pip xorg-xinput \
  lxappearance xorg-xsetroot \
  -y --needed

  pamac build picom-ibhagwan-git bspwm-git --no-confirm

  sudo pip3 install pywal
}

setup_for_gaming_with_steam() {
  sudo pacman -S \
  steam \
  -y --needed

  pamac build protonup-qt --no-confirm
}

setup_zsh_shell() {
  sudo pacman -S zsh --needed -y
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}



# pamac-aur

setup_pg_mysql_databases() {
  # article link
  # https://linuxhint.com/install-pgadmin4-manjaro-linux/

  sudo pacman -S postgresql --needed -y

  sudo mkdir /var/lib/pgadmin
  sudo mkdir /var/log/pgadmin
  sudo chown $USER /var/lib/pgadmin
  sudo chown $USER /var/log/pgadmin

  echo "Copy below line and paste in postgres console"
  echo "initdb --locale $LANG -E UTF8 -D '/var/lib/postgres/data/'"
  read -p "Press (Y/y) after copying above line " op
  if [ "$op" == "y" ]; then  
    sudo -u postgres -i
  elif [ "$op" == "Y" ]; then
    sudo -u postgres -i
  else
    echo "Existing"
    exit 1
  fi
  # sudo systemctl enable --now postgresql
  # psql -U postgres
  # \password
  # \q
}



register_aliases() {
  echo "# Sourcing .zzzz" >> "$HOME/.bashrc"
  echo "# Sourcing .zzzz" >> "$HOME/.zshrc"
  
  echo 'if [ -f ~/.zzzz ]; then' >> "$HOME/.bashrc"
  echo 'if [ -f ~/.zzzz ]; then' >> "$HOME/.zshrc"

  echo '  . ~/.zzzz ' >> "$HOME/.bashrc"
  echo '  . ~/.zzzz ' >> "$HOME/.zshrc"

  echo 'fi' >> "$HOME/.bashrc"
  echo 'fi ' >> "$HOME/.zshrc"
}

install_package_managers() {
  echo "Which package manager(s) would you like to install? "
  echo "1) yay (Comes with EndeavourOS)"
  echo "2) snapd"
  echo "3) pamac Gui (Does not comes in EndeavourOS)"
  read -p "Select package manager(s) separated by space. ex: 1 3 " package_manager

  for i in $package_manager; do
    case $i in
      1)
        pamac build yay --no-confirm
        ;;
      2)
        sudo pacman -S snapd --needed -y
        sudo systemctl enable --now snapd
        ;;
      3)
        pamac build pamac-aur --no-confirm
        ;;
      *)
        echo "Invalid selection"
        ;;
    esac
  done
}



echo "What would you like to do?"
echo "0. Setup All"
echo "1. Apply Dotfiles"
echo "2. Setup ZSH Shell"
echo "3. Register Aliases"
echo "4. Install Packages"
echo "5. Build AUR Packages"
echo "6. Setup Window Manager BSPWM"
echo "7. Setup For Gaming With Steam"
echo "8.Install Package Managers (Snapd/PamacGUI,Yay)"
echo "9. Setup Postgres/Mysql Databases"


while true; do
  read -rp "Enter the number of your choice: " choice

  case "$choice" in
    0)
      applyDotFiles
      setup_zsh_shell
      register_aliases
      install_packages
      build_aur_packages
      setup_window_manager_bspwm
      setup_for_gaming_with_steam
      setup_pg_mysql_databases
      break
      ;;
    1)
      applyDotFiles
      break
      ;;
    2)
      setup_zsh_shell
      break
      ;;
    3)
      register_aliases
      break
      ;;
    4)
      install_packages
      break
      ;;
    5)
      build_aur_packages
      break
      ;;
    6)
      setup_window_manager_bspwm
      break
      ;;
    7)
      setup_for_gaming_with_steam
      break
      ;;
    8)
      install_package_managers
      break
      ;;
    9)
      setup_pg_mysql_databases
      break
      ;;
    *)
      echo "Invalid option."
      ;;
  esac
done
