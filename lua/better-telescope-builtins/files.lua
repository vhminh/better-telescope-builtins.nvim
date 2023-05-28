local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local conf = require('telescope.config').values
local notify = require('telescope.utils').notify
local make_entry = require 'telescope.make_entry'
local entry_display = require 'telescope.pickers.entry_display'
local utils = require('better-telescope-builtins.utils')
local strings = require('plenary.strings')

local file_entry_maker = function(opts)
  opts = opts or {}
  local default_entry_maker = make_entry.gen_from_file(opts)
  local iconwidth = (not opts.disable_devicons) and 1 or 0
  local displayer = entry_display.create({
    separator = ' ',
    items = {
      { width = iconwidth, },
      { width = nil, },
      { remaining = true, },
    },
  })
  local my_entry_maker = function(line)
    local entry = default_entry_maker(line)
    entry.display = function(e)
      local entry_width = utils.get_entry_width()
      local icon, icon_hl = utils.devicon_for(e.value, opts)
      local padding = 8
      local max_path_len = entry_width - (icon and 2 or 0) - padding
      local filename, parents_str = utils.filename_and_shorten_parents(e.value, max_path_len)
      return displayer {
        { icon,                                                                         icon_hl },
        { filename },
        { strings.align_str(parents_str, max_path_len + padding - #filename - 1, true), 'Comment' }
      }
    end
    return entry
  end
  return my_entry_maker
end

local find_files = function(opts)
  opts = opts or {}

  if opts.find_command == nil then
    opts.find_command = { 'fd', '--type', 'file', '--color', 'never', '--hidden', '--exclude', '.git' }
  end

  if opts.find_command[1] ~= 'fd' then
    notify('find_files', {
      msg = 'Please use fd in find_command',
      level = 'ERROR',
    })
    return
  end

  if 1 ~= vim.fn.executable 'fd' then
    notify('find_files', {
      msg = 'You need to install fd',
      level = 'ERROR',
    })
    return
  end

  if opts.cwd then
    opts.cwd = vim.fn.expand(opts.cwd)
  end

  opts.entry_maker = opts.entry_maker or file_entry_maker(opts)

  pickers
      .new(opts, {
        prompt_title = 'Find Files',
        finder = finders.new_oneshot_job(opts.find_command, opts),
        previewer = conf.file_previewer(opts),
        sorter = conf.file_sorter(opts),
      })
      :find()
end

return { find_files = find_files }
