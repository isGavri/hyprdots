# Automatically exec into fish shell if in Hyprland
if [[ "$XDG_CURRENT_DESKTOP" == "Hyprland" && -x "$(command -v fish)" ]]; then
  exec fish
fi

# fastfetch
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# source ~/.oh-my-zsh/custom/plugins/autocomplete/zsh-autocomplete.plugin.zsh
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
export PATH="$HOME/.npm-packages/bin:$PATH"
export EDITOR="nvim"
export ZSH="$HOME/.oh-my-zsh"

plugins=(git archlinux colorize colored-man-pages)

source $ZSH/oh-my-zsh.sh
bindkey              '^I'         menu-complete
bindkey "$terminfo[kcbt]" reverse-menu-complete


alias ls="ls --color=auto"
alias la="ls -a"
alias grep="grep --color=auto"
alias dotfiles='/usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME"'
eval "$(zoxide init zsh)" 2>/dev/null

. "$HOME/.local/share/../bin/env"
