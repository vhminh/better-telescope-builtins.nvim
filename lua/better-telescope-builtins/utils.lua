local get_status = require('telescope.state').get_status
local path_tail = require('telescope.utils').path_tail
local file_extension = require('telescope.utils').file_extension

local utils = {}

utils.get_entry_width = function()
  local status = get_status(vim.api.nvim_get_current_buf())
  return vim.api.nvim_win_get_width(status.results_win) - status.picker.selection_caret:len()
end

local reverse = function(list)
  local result = {}
  for i = #list, 1, -1 do
    result[#result + 1] = list[i]
  end
  return result
end

local shorten_path = function(dirs, max_len)
  if #dirs == 0 then
    return './'
  end
  if #dirs == 1 then
    return dirs[1]
  end
  local lefts = { dirs[1] }
  local rights = { dirs[#dirs] }
  local left_end = 1
  local right_start = #dirs
  local left_len = #lefts[1]
  local right_len = #rights[1]
  while left_end + 1 < right_start do
    if #lefts < #rights then
      if left_len + right_len + #dirs[left_end + 1] + #lefts + #rights > max_len then
        break
      end
      left_len = left_len + #dirs[left_end + 1]
      table.insert(lefts, dirs[left_end + 1])
      left_end = left_end + 1
    else
      if left_len + right_len + #dirs[right_start - 1] + #lefts + #rights > max_len then
        break
      end
      right_len = right_len + #dirs[right_start - 1]
      table.insert(rights, dirs[right_start - 1])
      right_start = right_start - 1
    end
  end
  rights = reverse(rights)
  local parts = {}
  for _, v in ipairs(lefts) do
    table.insert(parts, v)
  end
  if #lefts + #rights < #dirs then
    table.insert(parts, '...')
  end
  for _, v in ipairs(rights) do
    table.insert(parts, v)
  end
  return table.concat(parts, '/')
end

utils.filename_and_shorten_parents = function(path, max_len)
  local parents = vim.split(path, '/')
  local filename = table.remove(parents, #parents)
  local remain = max_len - #filename
  local parents_str = shorten_path(parents, remain)
  return filename, parents_str
end

utils.devicon_for = (function()
  local has_devicons, devicons = pcall(require, 'nvim-web-devicons')
  if has_devicons and not devicons.has_loaded() then
    devicons.setup()
  end
  return function(filepath, opts)
    opts = opts or {}
    local conf = require('telescope.config').values
    if not has_devicons or opts.disable_devicons or not filepath then
      return ''
    end

    local basename = path_tail(filepath)
    local icon, hl = devicons.get_icon(basename, file_extension(basename), { default = false })
    if not icon then
      icon, hl = devicons.get_icon(basename, nil, { default = true })
      icon = icon or ' '
    end
    if conf.color_devicons then
      return icon, hl
    else
      return icon, nil
    end
  end
end)()

return utils
