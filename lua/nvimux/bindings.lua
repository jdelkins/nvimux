local bindings = {}
local vars = require('nvimux.vars')
local fns = {}
local nvim = vim.api -- luacheck: ignore

local consts = {
  terminal_quit = '<C-\\><C-n>',
  esc = '<ESC>',
}

fns.nvim_do_bind = function(options)
    local escape_prefix = options.escape_prefix  or ''
    local mode = options.mode
    return function(cfg)
      local suffix = cfg.suffix
      local prefix = vars.local_prefix[mode] or vars.prefix
      if suffix == nil then
        suffix = string.sub(cfg.mapping, 1, 1) == ':' and '<CR>' or ''
      end
      nvim.nvim_command(mode .. 'noremap <silent> ' .. prefix .. cfg.key .. ' ' .. escape_prefix .. cfg.mapping .. suffix)
  end
end

fns.bind = {
  t = fns.nvim_do_bind{mode = 't', escape_prefix = consts.terminal_quit},
  i = fns.nvim_do_bind{mode = 'i', escape_prefix = consts.esc},
  n = fns.nvim_do_bind{mode = 'n'},
  v = fns.nvim_do_bind{mode = 'v'}
}

fns.bind_all_modes = function(options)
  for _, mode in ipairs(options.modes) do
    fns.bind[mode](options)
  end
end

bindings.bind = function(options)
  fns.bind_all_modes(options)
end

bindings.create_binding = function(modes, command)
    local tbl = {}
    tbl[table.concat(modes, "")] = { command }
    return tbl

end

bindings.bind_all = function(options)
  for _, bind in ipairs(options) do
    local key, cmd, modes = unpack(bind)
    bindings.mappings[key] = bindings.create_binding(modes, cmd)
  end
end

bindings.keymap = function(binding, context)
  local options = {silent = true}

  if (type(binding[3]) == "function") then
    vim.keymap.set(binding[1], context.prefix .. binding[2], binding[3], options)
  elseif (type(binding[3]) == "string") then
    local suffix = ''

    if binding.suffix == nil then
      -- TODO revisit
      suffix = string.sub(binding[3], 1, 1) == ':' and '<CR>' or ''
    else
      suffix = binding.suffix
    end

    if vim.tbl_contains(binding[1], 't') then
      binding[1] = vim.tbl_filter(function(mode) return mode ~= 't' end, binding[1])
      vim.keymap.set('t',
        context.prefix .. binding[2],
        consts.terminal_quit .. binding[3] .. suffix,
        options)
    elseif vim.tbl_contains(binding[1], 'i') then
      binding[1] = vim.tbl_filter(function(mode) return mode ~= 'i' end, binding[1])
      vim.keymap.set('i',
        context.prefix .. binding[2],
        consts.esc .. binding[3] .. suffix,
        options)
    end

    vim.keymap.set(binding[1], context.prefix .. binding[2], binding[3] .. suffix, options)
  end
end

return bindings
