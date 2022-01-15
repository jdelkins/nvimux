local vars = {}

local _buf = nil

local singleton_buf = function()
  if _buf == nil or not vim.api.nvim_buf_is_loaded(_buf) then
    local content

    _buf = vim.api.nvim_create_buf(false, true)
    local tp = type(vars.scratch_buf_content)
    if (tp == "table") then
      content = vars.scratch_buf_content
    elseif (tp == "function") then
      content = vars.scratch_buf_content()
    else
      content = { "" }
    end
    vim.api.nvim_buf_set_lines(_buf, 0, -1, false, content)
  end

  return _buf
end


vars.local_prefix = {
    n = nil,
    v = nil,
    i = nil,
    t = nil
  }

vars.quickterm = {
  scope = 'g',
  direction = 'botright',
  orientation = 'vertical',
  size = '',
  command = 'term',
}

vars.prefix = '<C-b>'
-- Deprecated
vars.vertical_split = ':NvimuxVerticalSplit'
vars.horizontal_split = ':NvimuxHorizontalSplit'

vars.close_term = function()
    vim.api.nvim_buf_delete(0, {force = true})
end

vars.scratch_buf_content = {
  ""
}

vars.new_buffer = function()
  return vim.api.nvim_create_buf(false, true)
end

vars.new_window = function()
    vim.api.nvim_set_current_buf(singleton_buf())
end

vars.new_tab = function()
    vim.api.nvim_set_current_buf(singleton_buf())
end

vars.quickterm.split_type = function(t)
  return t.direction .. ' ' .. t.orientation .. ' ' .. t.size .. 'split'
end

return vars
