-- Prevent loading if already loaded or in compatible mode
if vim.g.loaded_ibus or vim.o.compatible or not vim.env.DISPLAY then
  return
end

vim.g.loaded_ibus = 1

local ibus = require('ibus')

-- Initialize with current global variables
ibus.setup()

-- Create plug mappings
vim.keymap.set('i', '<Plug>IbusToggle', function()
  return ibus.toggle('i')
end, { silent = true, expr = true })

vim.keymap.set('n', '<Plug>IbusToggle', function()
  ibus.toggle('n')
end, { silent = true })

vim.keymap.set('i', '<Plug>IbusEngineNext', function()
  return ibus.insert_select(1)
end, { silent = true, expr = true })

vim.keymap.set('n', '<Plug>IbusEngineNext', function()
  ibus.normal_select(1)
end, { silent = true })

vim.keymap.set('i', '<Plug>IbusEnginePrev', function()
  return ibus.insert_select(-1)
end, { silent = true, expr = true })

vim.keymap.set('n', '<Plug>IbusEnginePrev', function()
  ibus.normal_select(-1)
end, { silent = true })

-- Set up default mappings if not disabled
if not vim.g.ibus_no_mappings then
  vim.keymap.set('i', '<C-A-I><C-A-I>', '<Plug>IbusToggle')
  vim.keymap.set('n', '<C-A-I><C-A-I>', '<Plug>IbusToggle')
  vim.keymap.set('i', '<C-A-I><C-A-P>', '<Plug>IbusEngineNext')
  vim.keymap.set('n', '<C-A-I><C-A-P>', '<Plug>IbusEngineNext')
  vim.keymap.set('i', '<C-A-I><C-A-O>', '<Plug>IbusEnginePrev')
  vim.keymap.set('n', '<C-A-I><C-A-O>', '<Plug>IbusEnginePrev')
end