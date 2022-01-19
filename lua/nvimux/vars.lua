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


--- Quickterm configuration
-- @table quickterm
-- @field scope Scope of quickterm. Can be one of: 'b', 'w', 't', 'g'
-- @field direction nvim's window direction
-- @field orientation nvim's window orientation
-- @field size size in columns/rows depending on orientation
-- @field command nvim command or lua function for the quickterm
vars.quickterm = {
  scope = 'g',
  direction = 'botright',
  orientation = 'vertical',
  size = '',
  command = 'term',
}

vars.prefix = '<C-b>'

--- Defines what is going to be displayed when a buffer is
-- required for a new window/tab.
-- By default, that content will be created once on a
-- non-listed scratch buffer.
vars.scratch_buf_content = {
  ""
}

--- Prepares a new window
--  Can be used to display dashboards, TODO lists or as a hook to invoke
--  other functions (like telescope).
-- Defaults to setting a scratch buffer whose contents are defined by
-- @{\\vars.scratch_buf_content}.
vars.new_window = function()
    vim.api.nvim_set_current_buf(singleton_buf())
end

--- Prepares a new tab
-- Can be used to display dashboards, TODO lists or as a hook to invoke
-- other functions (like telescope).
-- Defaults to setting a scratch buffer whose contents are defined by
-- @{\\vars.scratch_buf_content}.
vars.new_tab = function()
    vim.api.nvim_set_current_buf(singleton_buf())
end

--- Prepares the command that will be executed to create a new quickterm
vars.quickterm.split_type = function(t)
  return t.direction .. ' ' .. t.orientation .. ' ' .. t.size .. 'split'
end

return vars
