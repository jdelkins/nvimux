-- luacheck: globals vim
local nvim = vim.api
local operations = {}
local defaults = {
  prefix = '<C-b>',
  vertical_split = ':NvimuxVerticalSplit',
  horizontal_split = ':NvimuxHorizontalSplit',
  quickterm_scope = 'g',
  quickterm_direction = 'botright',
  quickterm_orientation = 'vertical',
  quickterm_size = '',
  new_term = 'term',
  close_term = ':x',
  new_window = 'enew'
}

local clone = function(curr)
  local new = {}
  for k, v in pairs(curr) do
    new[k] = v
  end

  return new
end

local nvim_proxy = {
  __index = function(_, key)
    local key_ = 'nvimux_' .. key
    local val = nil
    if nvim.nvim_call_function('exists', {key_}) == 1 then
      val = nvim.nvim_get_var(key_)
    end
    return val
  end
}

operations.new_config = function()
  local config = clone(defaults)
  setmetatable(config, nvim_proxy)

  return config
end


return operations
