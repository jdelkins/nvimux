local fns = {}

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

  vim.cmd('command! -nargs=' .. nargs .. ' ' .. options.name .. ' ' .. cmd)
end


local function capitalize_first(s)
	return string.upper(string.sub(s,1,1))..string.sub(s,2)
end
local function to_pascal(s)
	return (string.gsub(capitalize_first(s),"_(%w+)",capitalize_first))
end

fns.snake_to_pascal = to_pascal

return fns
