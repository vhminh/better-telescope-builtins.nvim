# better-telescope-builtins.nvim
My opinionated alternatives for telescope.nvim builtin pickers

## Dependencies
- [`fd`](https://github.com/sharkdp/fd)

## Installation
Using `packer.nvim`
```lua
local packer = require('packer')
local use = packer.use
packer.startup(function()
  use { 'nvim-telescope/telescope.nvim', requires = { { 'nvim-lua/popup.nvim' }, { 'nvim-lua/plenary.nvim' } } }
  use { 'vhminh/better-telescope-builtins.nvim', requires = 'nvim-telescope/telescope.nvim' }
end)
```

## Config
```lua
local pickers = require('better-telescope-builtins')
vim.keymap.set('n', '<leader>f', pickers.find_files)
```