local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	'neovim/nvim-lspconfig',
	'shaunsingh/nord.nvim',
	{
		'nvim-telescope/telescope.nvim',
		branch = '0.1.x',
		dependencies = {
			'nvim-lua/plenary.nvim',
			'nvim-tree/nvim-web-devicons',
		},
	},
	'nvim-tree/nvim-tree.lua',
})

vim.lsp.config["gopls"] = {
	cmd = { "gopls" },
	filetypes = { "go" },
	root_markers = { ".git" },
	settings = {
		gopls = {
			analyses = {
				unusedparams = true,
			},
			staticcheck = true,
			gofumpt = true,
		},
	},
}
vim.lsp.enable("gopls")

--[[ Should use defaults
vim.lsp.config["ts_ls"] = {
	cmd = { "typescript-language-server", "--stdio" },
	filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
}
]]
vim.lsp.enable("ts_ls")

vim.lsp.enable("yamlls")

--[[
vim.lsp.config("lsp-ai", {
	cmd = { "lsp-ai" },
	filetypes = { "go" },
	root_markers = { ".git" },
	init_options = {
		memory = {
			file_store = vim.empty_dict(),
		},
		models = {
			model1 = {
				type  ="ollama",
				model = "qwen2.5-coder:3b",
			},
		},
		chat = {{
			trigger = "",
			action_display_name = "Chat",
			model = "model1",
			parameters = {
				max_context = 4096,
				max_tokens = 1024,
				system = "You are a code assistant chatbot. The user will ask you for assistance coding and you will do your best to answer succinctly and accurately",
			},
		}},
	},
})
vim.lsp.enable("lsp-ai")
--]]

-- LSP
vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('UserLspConfig', {}),
	callback = function(ev)
		vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

		-- Buffer local mappings
		local opts = { buffer = ev.buf }
		vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
		vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
		vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
		vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
		vim.keymap.set('n', '<leader>c', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
		vim.keymap.set('n', '<space>f', function()
			vim.lsp.buf.format { async = true }
		end, opts)
	end,
})

-- Go imports and formatting
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.go",
	callback = function()
		local params = vim.lsp.util.make_range_params()
		params.context = {only = {"source.organizeImports"}}
		local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
		for cid, res in pairs(result or {}) do
			for _, r in pairs(res.result or {}) do
				if r.edit then
					local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
					vim.lsp.util.apply_workspace_edit(r.edit, enc)
				end
			end
		end
		vim.lsp.buf.format({async = false})
	end
})

-- Telescope
local telescope = require('telescope')
telescope.setup({
	pickers = {
		find_files = {
			hidden = true,
			theme = "dropdown",
			find_command = { "fdfind", "--type", "f", "--strip-cwd-prefix" },
		},
		live_grep = {
			theme = "dropdown",
		}
	}
})

local builtin = require('telescope.builtin')
local themes = require('telescope.themes')
vim.keymap.set('n', '<C-p>', builtin.find_files, {})
vim.keymap.set('n', '<C-f>', builtin.live_grep, {})
vim.keymap.set('n', '<C-s>', builtin.lsp_document_symbols, {})
vim.keymap.set('n', '<C-b>', builtin.buffers, {})
vim.keymap.set('n', 'gi', builtin.lsp_implementations, {})
vim.keymap.set('n', 'gr', builtin.lsp_references, {})
vim.api.nvim_create_autocmd("FileType", { pattern = "TelescopeResults", command = [[setlocal nofoldenable]] })

-- nvim-tree
require("nvim-tree").setup({
	actions = {
		open_file = {
			quit_on_open = true,
		}
	}
})
vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>')
