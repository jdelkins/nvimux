--[[
Nvimux: Neovim as a terminal multiplexer.

This is the lua reimplementation of VimL.
--]]
-- luacheck: globals unpack

local __dep_warn = true
local deprecated = function(msg)
  if __dep_warn then
    print(msg)
    __dep_warn = false
  end
end

local nvimux = {}
local bindings = require('nvimux.bindings')
local vars = require('nvimux.vars')
local fns = require('nvimux.fns')
local ui = require('nvimux.ui')

nvimux.debug = {}
nvimux.bindings = bindings
nvimux.config = {}
nvimux.term = {}
nvimux.term.prompt = {}
nvimux.commands = {}

-- [ Private variables and tables
local nvim = vim.api -- luacheck: ignore
local nvim_proxy = {
  __index = function(_, key)
    deprecated("Don't use the proxy to vim vars. It will be removed in the next version")
    local key_ = 'nvimux_' .. key
    local val = nil
    if fns.exists(key_) then
      val = vim.api.nvim_get_var(key_)
    end
    return val
  end
}

-- [[ Table of default bindings
-- Deprecated
bindings.mappings = {
  ['<C-r>']  = { nvi  = {':so $MYVIMRC'}},
  ['!']      = { nvit = {':wincmd T'}},
  ['%']      = { nvit = {function() return vars.vertical_split end}},
  ['\"']     = { nvit = {function() return vars.horizontal_split end}},
  ['-']      = { nvit = {':NvimuxPreviousTab'}},
  ['q']      = { nvit = {':NvimuxToggleTerm'}},
  ['w']      = { nvit = {':tabs'}},
  ['o']      = { nvit = {'<C-w>w'}},
  ['n']      = { nvit = {'gt'}},
  ['p']      = { nvit = {'gT'}},
  ['x']      = { nvi  = {':bd %'},
                 t    = {function() return vars.close_term end}},
  ['X']      = { nvi  = {':enew \\| bd #'}},
  ['h']      = { nvit = {'<C-w><C-h>'}},
  ['j']      = { nvit = {'<C-w><C-j>'}},
  ['k']      = { nvit = {'<C-w><C-k>'}},
  ['l']      = { nvit = {'<C-w><C-l>'}},
  [':']      = { t    = {':', suffix = ''}},
  ['[']      = { t    = {''}},
  [']']      = { t    = {':NvimuxTermPaste'}},
  [',']      = { t    = {'', nvimux.term.prompt.rename}},
  ['c']      = { nvit = {':NvimuxNewTab'}},
}

bindings.map_table = {}

-- Deprecated
local win_cmd = function(create_window)
      local select_buffer
    if type(vars.new_window) == "function" then
      select_buffer = vars.new_window
    else
      select_buffer = function()
        vim.api.nvim_command(vars.new_window)
      end
    end

    ui.on_new(create_window, select_buffer)
end

-- Deprecated
local tab_cmd = function(create_window)
  local select_buffer
  local selector = nvimux.context.new_tab or nvimux.context.new_window
  if type(selector) == "function" then
    select_buffer = selector
  else
    select_buffer = function()
      vim.api.nvim_command(selector)
    end
  end

  ui.on_new(create_window, select_buffer)
end

nvimux.commands.horizontal_split = function() return win_cmd[[spl|wincmd j]] end
nvimux.commands.vertical_split = function() return win_cmd[[vspl|wincmd l]] end
nvimux.commands.new_tab = function() return tab_cmd[[tabe]] end

-- Deprecated
local nvimux_commands = {
  {name = 'NvimuxPreviousTab', cmd = [[lua require('nvimux').go_to_last_tab()]]},
  {name = 'NvimuxSet', cmd = [[lua require('nvimux').config.set_fargs(<f-args>)]], nargs='+'},
}

local autocmds = {
  {event = "TabLeave", target="*", cmd = [[lua require('nvimux').set_last_tab()]]},
}

local mappings = {
  -- Reload global configs
  {{'n', 'v', 'i'},      '<C-r>', ':so $MYVIMRC'},

  -- Window management
  {{'n', 'v', 'i', 't'}, '!',  ':wincmd T'},
  {{'n', 'v', 'i', 't'}, '%',  nvimux.commands.vertical_split},
  {{'n', 'v', 'i', 't'}, '\"', nvimux.commands.horizontal_split},
  {{'n', 'v', 'i', 't'}, '-',  nvimux.go_to_last_tab},
  {{'n', 'v', 'i', 't'}, 'q',  nvimux.term.toggle },
  {{'n', 'v', 'i', 't'}, 'w',  ':tabs'},
  {{'n', 'v', 'i', 't'}, 'o',  '<C-w>w'},
  {{'n', 'v', 'i', 't'}, 'n',  'gt'},
  {{'n', 'v', 'i', 't'}, 'p',  'gT'},
  {{'n', 'v', 'i'},      'x',  ':bd %'},
  {{'t'},                'x',  function() vim.api.nvim_buf_delete(0, {force = true}) end},
  {{'n', 'v', 'i'},      'X',  ':enew \\| bd #'},

  -- Moving around
  {{'n', 'v', 'i', 't'}, 'h',  '<C-w><C-h>'},
  {{'n', 'v', 'i', 't'}, 'j',  '<C-w><C-j>'},
  {{'n', 'v', 'i', 't'}, 'k',  '<C-w><C-k>'},
  {{'n', 'v', 'i', 't'}, 'l',  '<C-w><C-l>'},

  -- Term facilities
  {{'t'},                ':',  ':', suffix = ''},
  {{'t'},                '[',  ''},
  {{'t'},                ']',  function() nvimux.term_only{cmd = 'normal pa'} end},
  {{'t'},                ',',  nvimux.term.prompt.rename},

  -- Tab management
  {{'n', 'v', 'i', 't'}, 'c',  nvimux.commands.new_tab},
  {{'n', 'v', 'i', 't'}, '0',  '0gt'},
  {{'n', 'v', 'i', 't'}, '1',  '1gt'},
  {{'n', 'v', 'i', 't'}, '2',  '2gt'},
  {{'n', 'v', 'i', 't'}, '3',  '3gt'},
  {{'n', 'v', 'i', 't'}, '4',  '4gt'},
  {{'n', 'v', 'i', 't'}, '5',  '5gt'},
  {{'n', 'v', 'i', 't'}, '6',  '6gt'},
  {{'n', 'v', 'i', 't'}, '7',  '7gt'},
  {{'n', 'v', 'i', 't'}, '8',  '8gt'},
  {{'n', 'v', 'i', 't'}, '9',  '9gt'},
}

-- ]]

setmetatable(vars, nvim_proxy)

-- ]

-- ]

nvimux.do_autocmd = function(commands)
  local au = {"augroup nvimux"}
  for _, v in ipairs(commands) do
    table.insert(au, "au! " .. v.event .. " " .. v.target .. " " .. v.cmd)
  end
  table.insert(au, "augroup END")
  nvim.nvim_call_function("execute", {au})
end

-- [ Public API
-- [[ Config-handling commands
nvimux.config.set = function(options)
  deprecated("nvimux.config.set is deprecated. Use nvimux.setup")
  vars[options.key] = options.value
end

nvimux.config.set_fargs = function(key, value)
  deprecated("nvimux.config.set_fargs is deprecated. Use nvimux.setup")
  nvimux.config.set{key=key, value=value}
end

nvimux.config.set_all = function(options)
  deprecated("nvimux.config.set_all is deprecated. Use nvimux.setup")
  for key, value in pairs(options) do
    nvimux.config.set{['key'] = key, ['value'] = value}
  end
end
-- ]]

-- [[ Quickterm
-- TODO port
nvimux.term.new_toggle = function()
  local split_type = nvimux.context.quickterm:split_type()
  nvim.nvim_command(split_type .. ' | enew | ' .. nvimux.context.quickterm.command)
  local buf_nr = nvim.nvim_call_function('bufnr', {'%'})
  nvim.nvim_set_option('wfw', true)
  vim.b[buf_nr].nvimux_buf_orientation = split_type
  vim[nvimux.context.quickterm.scope].nvimux_last_buffer_id = buf_nr
end

-- TODO port
nvimux.term.toggle = function()
  -- TODO Allow external commands
  local buf_nr = vim.g.nvimux_last_buffer_id

  if not buf_nr then
    nvimux.term.new_toggle()
  else
    local id = math.floor(buf_nr)
    local window = nvim.nvim_call_function('bufwinnr', {id})

    if window == -1 then
      if nvim.nvim_call_function('bufname', {id}) == '' then
        nvimux.term.new_toggle()
      else
        local split_type = vim.b[buf_nr].nvimux_buf_orientation
        nvim.nvim_command(split_type .. ' | b' .. id)
      end
    else
      nvim.nvim_command(window .. ' wincmd w | q | stopinsert')
    end
  end
end

nvimux.term.prompt.rename = function()
  nvimux.term_only{
    cmd = fns.prompt('nvimux > New term name: '),
    action = function(k) vim.api.nvim_command('file term://' .. k) end
  }
end
-- ]]

-- [[ Bindings
-- ]]

-- [[ Top-level commands
nvimux.debug.context = function()
  print(vim.inspect(nvimux.context))
end

nvimux.debug.bindings = function()
  print(vim.inspect(nvimux.context.bindings))
end

nvimux.debug.state = function()
  print(vim.inspect(nvimux.context.state))
end

nvimux.term_only = function(options)
  local action = options.action or vim.api.nvim_command
  if vim.bo.buftype == 'terminal' then
    action(options.cmd)
  else
    print("Not on terminal")
  end
end

-- deprecated
nvimux.mapped = function(options)
  local mapping = bindings.map_table[options.key]
  local ret = mapping.arg()
  if ret ~= '' and ret ~= nil then
    nvim.nvim_command(ret)
  end
end

nvimux.set_last_tab = function(tabn)
  if tabn == nil then
    tabn = nvim.nvim_call_function('tabpagenr', {})
  end

  nvimux.context.state.last_tab = tabn
end

nvimux.go_to_last_tab = function()
  nvim.nvim_command((nvimux.context.state.last_tab or 1)  .. 'tabn')
end

 -- ]]
-- ]


nvimux.bootstrap = function(force)
  deprecated("nvimux.bootstrap is deprecated. Use nvimux.setup")
  if force or nvimux.loaded == nil then
    for i=1, 9 do
      bindings.mappings[i] = bindings.create_binding({"n", "v", "i", "t"} , i .. 'gt')
    end

    for _, cmd in ipairs(nvimux_commands) do
      fns.build_cmd(cmd)
    end

    for key, cmd in pairs(bindings.mappings) do
      for modes, binds in pairs(cmd) do
        modes = fns.split(modes)
        local arg = table.remove(binds, 1)
        binds.key = key
        binds.modes = modes
        if type(arg) == 'function' then
          bindings.map_table[key] = {['arg'] = arg, ['action'] = nil}
          binds.mapping = ":lua require('nvimux').mapped{key = '" .. key .. "'}"
        else
          binds.mapping = arg
        end
        bindings.bind(binds)
      end
    end
    fns.build_cmd{name = 'NvimuxReload', cmd = 'lua require("nvimux").bootstrap(true)'}
    nvimux.do_autocmd(autocmds)
    nvimux.loaded = true
  end
end
-- ]

--[[
nvimux.setup{
  config = {
    prefix = '<c-a>'
  },
  bindings = {
    {{'n'}, '<space>', function() print("hello!") end},
  }
}
--]]
nvimux.setup = function(opts)
  if (vim.keymap == nil) then
    print("Aborting setup of nvimux. vim.keymap not found")
    return
  end
  -- TODO Remove global vars, make it local to context only
  vars = vim.tbl_deep_extend("force", vars or {}, opts.config or {})

  local context = vars
  context.bindings = vim.tbl_deep_extend("force", mappings, opts.bindings or {})

  for _, binding in ipairs(context.bindings) do
    bindings.keymap(binding, context)
  end

  context.autocmds = vim.tbl_deep_extend("force", autocmds, opts.autocmds or {})
  nvimux.do_autocmd(context.autocmds)

  context.state = {}

  nvimux.context = context
end

return nvimux
