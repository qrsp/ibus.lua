local M = {}

-- Module state
local ibus_enabled = false
local insert_engines_idx = 0
local normal_engines_idx = 0
local current_engine = nil

-- Configuration defaults
local config = {
	insert_engines = vim.g.ibus_insert_engines or {},
	normal_engines = vim.g.ibus_normal_engines or {},
	no_mappings = vim.g.ibus_no_mappings or false,
}

-- Check if we have a display (X11 environment)
local function has_display()
	return vim.env.DISPLAY ~= nil
end

-- Execute ibus command to set engine
local function set_engine(engine)
	if not engine then
		return
	end

  vim.system({ "ibus", "engine", engine }, {})
end

-- Switch to insert mode engine
function M.insert()
	if #config.insert_engines == 0 then
		return
	end

	local engine = config.insert_engines[insert_engines_idx + 1] -- Lua is 1-indexed
	if engine then
		current_engine = engine
		set_engine(engine)
	end
end

-- Switch to normal mode engine
function M.normal()
	if #config.normal_engines == 0 then
		return
	end

	local engine = config.normal_engines[normal_engines_idx + 1] -- Lua is 1-indexed
	if engine then
		current_engine = engine
		set_engine(engine)
	end
end

-- Handle focus events
function M.focus()
	if current_engine then
		set_engine(current_engine)
	end
end

-- Toggle ibus.vim on/off
function M.toggle(mode)
	if not has_display() then
		vim.notify("No DISPLAY environment variable found", vim.log.levels.ERROR)
		return ""
	end

	if ibus_enabled then
		ibus_enabled = false
		vim.notify("IBUS.VIM DISABLE.", vim.log.levels.INFO)

		-- Clear autocommands
		vim.api.nvim_clear_autocmds({ group = "ibus_vim" })
	else
		ibus_enabled = true
		vim.notify("IBUS.VIM ENABLE.", vim.log.levels.INFO)

		-- Set initial engine based on mode
		if mode == "i" then
			M.insert()
		else
			M.normal()
		end

		-- Set up autocommands
		local augroup = vim.api.nvim_create_augroup("ibus_vim", { clear = true })

		vim.api.nvim_create_autocmd("InsertEnter", {
			group = augroup,
			callback = M.insert,
		})

		vim.api.nvim_create_autocmd("InsertLeavePre", {
			group = augroup,
			callback = M.normal,
		})

		vim.api.nvim_create_autocmd("CmdlineEnter", {
			group = augroup,
			pattern = { "[/\\?]" },
			callback = M.insert,
		})

		vim.api.nvim_create_autocmd("CmdlineLeave", {
			group = augroup,
			pattern = { "[/\\?]" },
			callback = M.normal,
		})

		vim.api.nvim_create_autocmd("FocusGained", {
			group = augroup,
			callback = M.focus,
		})
	end

	return ""
end

-- Select next/previous insert engine
function M.insert_select(offset)
	if #config.insert_engines == 0 then
		return ""
	end

	insert_engines_idx = (insert_engines_idx + offset) % #config.insert_engines
	if insert_engines_idx < 0 then
		insert_engines_idx = insert_engines_idx + #config.insert_engines
	end

	M.insert()
	return ""
end

-- Select next/previous normal engine
function M.normal_select(offset)
	if #config.normal_engines == 0 then
		return ""
	end

	normal_engines_idx = (normal_engines_idx + offset) % #config.normal_engines
	if normal_engines_idx < 0 then
		normal_engines_idx = normal_engines_idx + #config.normal_engines
	end

	M.normal()
	return ""
end

-- Update configuration
function M.setup(opts)
	opts = opts or {}
	config.insert_engines = opts.insert_engines or vim.g.ibus_insert_engines or {}
	config.normal_engines = opts.normal_engines or vim.g.ibus_normal_engines or {}
	config.no_mappings = opts.no_mappings or vim.g.ibus_no_mappings or false
end

return M
