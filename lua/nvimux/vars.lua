local vars = {}

vars.local_prefix = {
    n = nil,
    v = nil,
    i = nil,
    t = nil
  },

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
    vim.api.nvim_set_current_buf(require("nvimux.ui").singleton_buf())
end

vars.new_tab = function()
    vim.api.nvim_set_current_buf(require("nvimux.ui").singleton_buf())
end

vars.quickterm.split_type = function(t)
  return t.direction .. ' ' .. t.orientation .. ' ' .. t.size .. 'split'
end

return vars
