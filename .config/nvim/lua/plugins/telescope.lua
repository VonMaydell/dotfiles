local telescope = require("telescope")

telescope.setup({
	pickers = {
		find_files = {
			hidden = true,
			theme = "dropdown",
			find_command = { "fdfind", "--type", "f", "--strip-cwd-prefix" },
		},
		live_grep = {
			theme = "dropdown",
		},
	},
})

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<C-p>", builtin.find_files, {})
vim.keymap.set("n", "<C-f>", builtin.live_grep, {})
vim.keymap.set("n", "<C-s>", builtin.lsp_document_symbols, {})
vim.keymap.set("n", "<C-b>", builtin.buffers, {})
vim.keymap.set("n", "gi", builtin.lsp_implementations, {})
vim.keymap.set("n", "gr", builtin.lsp_references, {})
vim.api.nvim_create_autocmd("FileType", { pattern = "TelescopeResults", command = [[setlocal nofoldenable]] })
