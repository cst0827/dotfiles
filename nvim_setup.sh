# Debian package is very slow, we will most likely build Neovim from source.
# See these links for more information on that:
# https://github.com/neovim/neovim/blob/master/INSTALL.md#install-from-source
# https://github.com/neovim/neovim/blob/master/BUILD.md#quick-start

# for Copilot.nvim, it needs Node.js 20.x or newer
# if use nvm to install nodejs, make sure to:
#   1. call `nvm deactivate`, use `which node` to check current nodejs path, it should not be in ~/.nvm
#   2. re-run some of the steps in Build_Debian11.sh (not sure which ones)
#   3. make sure QSM project build is successful
# if node version changed, also change vim.g.copilot_node_command in copilot.lua
# Maybe use zbirenbaum/copilot.lua instead?

# Maybe install telescope?

# Once Neovim is installed, just copy everything under ./nvim into ~/.config/nvim
