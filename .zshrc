export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

plugins=(git)

source $ZSH/oh-my-zsh.sh
autoload -Uz compinit && compinit

alias gdelete='git branch | grep -v "^*" | cut -c 3- | fzf --layout reverse  --info inline --multi --print0 | xargs -0 git branch -D'
function gcheckout() {
  git branch | grep -v "^*" | cut -c 3- | fzf | xargs git checkout
}

case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

eval "$(zoxide init zsh --cmd cd)"
eval "$(fzf --zsh)"

export NVM_DIR="$HOME/.nvm"
export EDITOR=nvim
export VISUAL="$EDITOR"

export COREPACK_ENABLE_AUTO_PIN=0

if [[ -e ~/.zshrc_priv ]]; then
    source ~/.zshrc_priv
fi
