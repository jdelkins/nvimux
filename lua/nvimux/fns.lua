local fns = {}
local nvim = vim.api -- luacheck: ignore

fns.exists = function(var)
  return nvim.nvim_call_function('exists', {var}) == 1
end

fns.clone = function(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[fns.clone(orig_key)] = fns.clone(orig_value)
        end
        setmetatable(copy, fns.clone(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

fns.prompt = function(message)
  nvim.nvim_call_function('inputsave', {})
  local ret = nvim.nvim_call_function('input', {message})
  nvim.nvim_call_function('inputrestore', {})
  return ret
end

fns.split = function(str)
  local p = {}
  for i=1, #str do
    table.insert(p, str:sub(i, i))
  end
  return p
end

fns.build_cmd = function(options)
  local nargs = options.nargs or 0
  local cmd = options.cmd or options.lazy_cmd()

  nvim.nvim_command('command! -nargs=' .. nargs .. ' ' .. options.name .. ' ' .. cmd)
end

return fns.clone(fns)
