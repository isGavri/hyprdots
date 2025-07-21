#!/bin/bash

clear
usuario=$(whoami)
sudo usermod -a -G input $usuario
echo "Are you logged on Hyprland right now? [Y/N]"
read hypr
option="${hypr^^}"
if [ "$option" == "Y" ]; then
else
    echo "When you log on hyprland, run this script again to set you monitor and refresh rate"
    sleep 4
fi
clear
cp -r ./fastfetch ./hypr ./kitty ./rofi ./waybar ./spicetify -t ~/.config
# cp -r ./themes -t ~/Documents/

sudo cp -r ./icons/* -t /usr/share/icons/

sudo cp -r ./themes/* -t /usr/share/themes/
cp -r ./.zshrc ./.p10k.zsh -t ~/

nohup swww-daemon > /dev/null 2>&1 &
swww img ~/.config/hypr/wallpaper.jpg &> /dev/null
killall waybar &> /dev/null
waybar &> /dev/null &

hyprctl setcursor rose-pine-hyprcursor 24

sudo chmod -R 777 /usr/share/themes
sudo chmod -R 777 /usr/share/icons
sudo chmod -R 777 /usr/bin/papirus-folders

gsettings set org.gnome.desktop.interface icon-theme 'Gruvbox-Material-Dark' &> /dev/null
gsettings set org.gnome.desktop.interface gtk-theme "Gruvbox-Material-Dark" &> /dev/null
gsettings set org.gnome.desktop.interface cursor-theme 'rose-pine-hyprcursor' &> /dev/null

papirus-folders -C cat-mocha-yellow &> /dev/null

