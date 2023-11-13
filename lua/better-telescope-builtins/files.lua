local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local notify = require('telescope.utils').notify
local make_entry = require('telescope.make_entry')
local entry_display = require('telescope.pickers.entry_display')
local utils = require('better-telescope-builtins.utils')
local strings = require('plenary.strings')

local M = {}

local file_entry_maker = function(opts)
  opts = opts or {}
  local default_entry_maker = make_entry.gen_from_file(opts)
  local iconwidth = (not opts.disable_devicons) and 1 or 0
  local displayer = entry_display.create({
    separator = ' ',
    items = {
      { width = iconwidth },
      { width = nil },
      { remaining = true },
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
      return displayer({
        { icon, icon_hl },
        { filename },
        { strings.align_str(parents_str, max_path_len + padding - #filename - 1, true), 'Comment' },
      })
    end
    return entry
  end
  return my_entry_maker
end

M.find_files = function(opts)
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

  if 1 ~= vim.fn.executable('fd') then
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

local buffer_entry_maker = function(opts)
  opts = opts or {}
  local default_entry_maker = make_entry.gen_from_buffer(opts)
  local iconwidth = (not opts.disable_devicons) and 1 or 0
  local displayer = entry_display.create({
    separator = ' ',
    items = {
      { width = opts.bufnr_width },
      { width = 4 },
      { width = iconwidth },
      { width = nil },
      { remaining = true },
    },
  })
  local my_entry_maker = function(line)
    local entry = default_entry_maker(line)
    entry.display = function(e)
      local entry_width = utils.get_entry_width()
      local icon, icon_hl = utils.devicon_for(e.value, opts)
      local padding = 8
      local max_path_len = entry_width - (opts.bufnr_width + 1) - (icon and 2 or 0) - 5 - padding
      local filename, parents_str = utils.filename_and_shorten_parents(e.value, max_path_len)
      return displayer({
        { entry.bufnr, 'TelescopeResultsNumber' },
        { entry.indicator, 'TelescopeResultsComment' },
        { icon, icon_hl },
        { filename },
        { strings.align_str(parents_str, max_path_len + padding - #filename - 1, true), 'Comment' },
      })
    end
    return entry
  end
  return my_entry_maker
end

M.buffers = function(opts)
  opts = opts or {}
  local bufnrs = vim.tbl_filter(function(b)
    if 1 ~= vim.fn.buflisted(b) then
      return false
    end
    -- only hide unloaded buffers if opts.show_all_buffers is false, keep them listed if true or nil
    if opts.show_all_buffers == false and not vim.api.nvim_buf_is_loaded(b) then
      return false
    end
    if opts.ignore_current_buffer and b == vim.api.nvim_get_current_buf() then
      return false
    end
    if opts.cwd_only and not string.find(vim.api.nvim_buf_get_name(b), vim.loop.cwd(), 1, true) then
      return false
    end
    if not opts.cwd_only and opts.cwd and not string.find(vim.api.nvim_buf_get_name(b), opts.cwd, 1, true) then
      return false
    end
    return true
  end, vim.api.nvim_list_bufs())

  if not opts.bufnr_width then
    local max_bufnr = math.max(unpack(bufnrs))
    opts.bufnr_width = #tostring(max_bufnr)
  end

  opts.entry_maker = buffer_entry_maker(opts)
  require('telescope.builtin').buffers(opts)
end

return M
