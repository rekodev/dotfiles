# Dotfiles cheatsheet

Quick guide to re-linking this repo on a fresh machine.

## Caution

Back up any existing files before linking, and run stow from your dotfiles
folder to avoid targeting the wrong source.

## 1) Stow packages

Use stow to link package folders into place:

```sh
stow -d ~/dotfiles -t ~/.config .config
stow -d ~/dotfiles -t ~ bat
```

If you already have live files there, back them up first:

```sh
backup_dir="$HOME/.config/_dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$backup_dir"
mv "$HOME/.config/ghostty" "$HOME/.config/lazygit" "$HOME/.config/nvim" \
  "$HOME/config" "$HOME/themes" "$backup_dir"
```

## 2) Link top-level dotfiles directly

These files live at the top level of the dotfiles folder, so they are
symlinked directly:

```sh
ln -s ~/dotfiles/.gitconfig_pub ~/.gitconfig_pub
ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
ln -s ~/dotfiles/.zshrc ~/.zshrc
```

If you already have live files, back them up first:

```sh
backup_dir="$HOME/_dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$backup_dir"
mv "$HOME/.tmux.conf" "$HOME/.zshrc" "$backup_dir"
```

## 3) Verify links

```sh
ls -l ~/.config/ghostty ~/.config/lazygit ~/.config/nvim \
  ~/.gitconfig_pub ~/.tmux.conf ~/.zshrc ~/config ~/themes
```

## Notes

- If you want stow to manage root dotfiles, move them into a package
  directory (e.g. `dotfiles/home/.zshrc`) and then `stow -t ~ home`.
