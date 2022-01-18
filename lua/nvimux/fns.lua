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

return fns
