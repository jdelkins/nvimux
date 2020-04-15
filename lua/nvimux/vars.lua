local vars = {
  prefix = '<C-b>',
  local_prefix = {
    n = nil,
    v = nil,
    i = nil,
    t = nil
  },
  vertical_split = ':NvimuxVerticalSplit',
  horizontal_split = ':NvimuxHorizontalSplit',
  quickterm_scope = 'g',
  quickterm_direction = 'botright',
  quickterm_orientation = 'vertical',
  quickterm_size = '',
  quickterm_command = 'term',
  close_term = ':x',
  new_window = 'enew',
  new_tab = nil
}

vars.split_type = function(t)
  return t.quickterm_direction .. ' ' .. t.quickterm_orientation .. ' ' .. t.quickterm_size .. 'split'
end

return vars
