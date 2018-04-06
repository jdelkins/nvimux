# NVIMUX

Nvimux allows neovim to work as a tmux replacement.

It does so by mapping tmuxs keybindings to neovim, using its windows, buffers and terminals.

### Support nvimux
Support nvimux development by sending me some bitcoins at `137gRFaXxJmyV23FA9PZZ6Fp8Pvs11gPPV`.

## Configuring

Nvimux is built on [lua](https://github.com/neovim/neovim/pull/4411), meaning that you must use a somewhat recent version of neovim.

For the older version, based on viml, refer to [the legacy branch](https://github.com/hkupty/nvimux/tree/legacy). The legacy branch won't be maintained but will be kept for those who prefer it.

To configure nvimux, you can use both lua and viml to configure, though the first is much preferred.

A lua-based configuration for nvimux is as follows:

```lua
lua << EOF
local nvimux = require('nvimux')

-- Nvimux configuration
nvimux.config.set_all{
  prefix = '<C-a>',
  new_window = 'enew', -- Use 'term' if you want to open a new term for every new window
  new_tab = nil, -- Defaults to new_window. Set to 'term' if you want a new term for every new tab
  new_window_buffer = 'single',
  quickterm_direction = 'botright',
  quickterm_orientation = 'vertical',
  -- Use 'g' for global quickterm
  quickterm_scope = 't',
  quickterm_size = '80',
}

-- Nvimux custom bindings
nvimux.bindings.bind_all{
  {'s', ':NvimuxHorizontalSplit', {'n', 'v', 'i', 't'}},
  {'v', ':NvimuxVerticalSplit', {'n', 'v', 'i', 't'}},
}

-- Required so nvimux sets the mappings correctly
nvimux.bootstrap()
EOF
```

In case you don't set configuration options, please do run the following for nvimux to work:
```lua
lua require('nvimux').bootstrap()
```

On viml, the variables can be defined using the same name, prepending `nvimux_` to it:

```viml
  let g:nvimux_prefix = '<C-a>',
  let g:nvimux_open_term_by_default = true,
  let g:nvimux_new_window_buffer = 'single',
  let g:nvimux_quickterm_direction = 'botright',
  let g:nvimux_quickterm_orientation = 'vertical',
  let g:nvimux_quickterm_scope = 't',
  let g:nvimux_quickterm_size = '80',
```

## Credits & Stuff

This plugin is developed and maintained by [Henry Kupty](http://github.com/hkupty) and it's completely free to use.
The rationale behind the idea is described [in this article](http://hkupty.github.io/2016/Ditching-TMUX/).
Consider helping by opening issues, Pull Requests or influencing your friends and colleagues to use!
