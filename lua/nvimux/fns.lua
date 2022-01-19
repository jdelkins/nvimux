local fns = {}

local function capitalize_first(s)
  return string.upper(string.sub(s,1,1))..string.sub(s,2)
end

fns.snake_to_pascal = function(s)
  return (string.gsub(capitalize_first(s),"_(%w+)",capitalize_first))
end

fns.fn_or_command = function(cmd)
  local tp = type(cmd)
  if tp == "function" then
    cmd()
  elseif tp == "string" then
    vim.cmd(cmd)
  else
    print("nvimux: Cannot run command of type " .. tp)
  end
end


return fns
