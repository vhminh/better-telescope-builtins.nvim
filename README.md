# better-telescope-builtins.nvim
My opinionated alternatives for telescope.nvim builtin pickers

<table>
<tr>
<td><strong>Original telescope builtin file picker</strong></td>
<td><strong>My file picker</strong></td>
<tr>
<tr>
<td><img src="https://github.com/vhminh/better-telescope-builtins.nvim/assets/40837587/59767644-79d9-457f-80db-0c20d498b929" width=100% height=100%></td>
<td><img src="https://github.com/vhminh/better-telescope-builtins.nvim/assets/40837587/7db9afed-7a6a-45e6-b888-05f0c176b231" width=100% height=100%></td>
<tr>
</table>

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
