#!/usr/bin/env bash
# install.sh - Interactive Arch Linux bootstrap script
# First version: handles pacman, aur, and service setup

set -euo pipefail

PACMAN_PKGS_FILE="install/pacman"
AUR_PKGS_FILE="install/aur"

# Colors
RED=$(tput setaf 1)
GRN=$(tput setaf 2)
YEL=$(tput setaf 3)
BLU=$(tput setaf 4)
RST=$(tput sgr0)

confirm() {
    # ask for confirmation (Y/n)
    read -rp "${YEL}$1 [Y/n]: ${RST}" response
    case "$response" in
        [nN][oO]|[nN]) return 1 ;;
        *) return 0 ;;
    esac
}

msg() {
    echo -e "${BLU}==>${RST} $1"
}

err() {
    echo -e "${RED}ERROR:${RST} $1" >&2
}

# Ensure script is run on Arch Linux
if [[ ! -f /etc/arch-release ]]; then
    err "This script must be run on Arch Linux!"
    exit 1
fi

# Update system
if confirm "Do you want to update the system with pacman -Syu?"; then
    sudo pacman -Syu --noconfirm
fi

# Install pacman packages
if [[ -f "$PACMAN_PKGS_FILE" ]]; then
    msg "Reading pacman package list from $PACMAN_PKGS_FILE"
    mapfile -t pkgs < "$PACMAN_PKGS_FILE"
    if [[ ${#pkgs[@]} -gt 0 ]]; then
        echo "Packages: ${pkgs[*]}"
        if confirm "Install these packages with pacman?"; then
            sudo pacman -S --needed --noconfirm "${pkgs[@]}"
        fi
    fi
else
    msg "No $PACMAN_PKGS_FILE found, skipping pacman packages"
fi

# Install AUR helper if needed (yay)
if [[ -f "$AUR_PKGS_FILE" ]]; then
    if ! command -v yay >/dev/null 2>&1; then
        if confirm "yay is not installed. Install yay AUR helper?"; then
            tmpdir=$(mktemp -d)
            git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
            pushd "$tmpdir/yay"
            makepkg -si --noconfirm
            popd
            rm -rf "$tmpdir"
        else
            err "Cannot install AUR packages without yay."
        fi
    fi
    if command -v yay >/dev/null 2>&1; then
        msg "Reading AUR package list from $AUR_PKGS_FILE"
        mapfile -t aurpkgs < "$AUR_PKGS_FILE"
        if [[ ${#aurpkgs[@]} -gt 0 ]]; then
            echo "AUR packages: ${aurpkgs[*]}"
            if confirm "Install these AUR packages with yay?"; then
                yay -S --needed --noconfirm "${aurpkgs[@]}"
            fi
        fi
    fi
fi

# Enable & start services
SERVICES=(NetworkManager bluetooth mariadb pipewire pipewire-pulse wireplumber)

msg "Configuring services..."

# Setup MariaDB before enabling the service
if command -v mariadb-install-db >/dev/null 2>&1; then
    if [[ ! -d /var/lib/mysql/mysql ]]; then
        msg "Initializing MariaDB system database..."
        if confirm "Run mariadb-install-db now?"; then
            sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
        fi
    else
        msg "MariaDB system database already initialized, skipping."
    fi
fi
for svc in "${SERVICES[@]}"; do
    if systemctl list-unit-files | grep -q "^${svc}\.service"; then
        if confirm "Enable & start $svc.service?"; then
            sudo systemctl enable --now "$svc.service"
        fi
    else
        msg "Skipping $svc.service (not installed)"
    fi
done

msg "Setup complete! You may want to reboot."
