ln -s ~/repos/nixos-config/nixos-ssh-config ~/.ssh/config

mkdir ~/repos

git clone git@github.com:nodu/nixos-config.git ~/repos/nixos-config
git clone git@github.com:nodu/defaults.git ~/repos/defaults/
git clone git@github.com:nodu/dotenv.git ~/repos/dotenv/
git clone git@github.com:nodu/notes.git ~/repos/notes
git clone git@github.com:nodu/todo.git ~/repos/todo

rm -rf ~/.config/nvim
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim
git clone git@github.com:nodu/lazystuff.git ~/.config/nvim/
nvim

# ln -s /host/matt/Downloads ~/Downloads
