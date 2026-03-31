-- Disable netrw in favor of neo-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Options
vim.opt.signcolumn = "yes"
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.opt.softtabstop = -1
vim.opt.shiftwidth = 4
vim.opt.clipboard = "unnamedplus"
vim.opt.scrolloff = 10
vim.opt.undofile = true
vim.opt.cursorline = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.list = true
vim.opt.smartcase = true
vim.opt.wrap = false
vim.opt.sidescrolloff = 36
local space = "·"
vim.opt.listchars:append({
	tab = "|·",
	multispace = space,
	lead = space,
	trail = space,
	nbsp = space,
})

-- Non-plugin keymaps
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Misc
vim.highlight.priorities.semantic_tokens = 75
vim.diagnostic.config({ update_in_insert = true })
vim.filetype.add({ extension = { avdl = "avdl" } })
vim.api.nvim_create_autocmd("BufWinEnter", { command = "set formatoptions-=cro" })

-- Lazygit helpers
function EditLineFromLazygit(file_path, line)
	local path = vim.fn.expand("%:p")
	if path == file_path then
		vim.cmd(tostring(line))
	else
		vim.cmd("e " .. file_path)
		vim.cmd(tostring(line))
	end
end

function EditFromLazygit(file_path)
	local path = vim.fn.expand("%:p")
	if path ~= file_path then
		vim.cmd("e " .. file_path)
	end
end

-- Plugin globals that must be set before plugins are loaded
vim.g.copilot_no_tab_map = true

vim.g.neominimap = {
	auto_enable = true,
	layout = "split",
	split = { minimap_width = 16 },
	git = {
		enabled = true,
		mode = "line",
		priority = 6,
		icon = { add = "+ ", change = "~ ", delete = "- " },
	},
}

-- Build hooks for plugins that need a post-install step
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		if ev.data.kind == "delete" then
			return
		end
		if ev.data.spec.name == "nvim-treesitter" then
			vim.cmd("TSUpdate")
		elseif ev.data.spec.name == "telescope-fzf-native.nvim" then
			vim.system({ "make" }, { cwd = ev.data.path })
		end
	end,
})

-- Plugins
vim.pack.add({
	"https://github.com/Isrothy/neominimap.nvim",
	"https://github.com/MunifTanjim/nui.nvim",
	"https://github.com/folke/ts-comments.nvim",
	"https://github.com/github/copilot.vim",
	"https://github.com/hrsh7th/cmp-nvim-lsp",
	"https://github.com/hrsh7th/cmp-nvim-lsp-signature-help",
	"https://github.com/hrsh7th/nvim-cmp",
	"https://github.com/kdheepak/lazygit.nvim",
	"https://github.com/lewis6991/gitsigns.nvim",
	"https://github.com/lukas-reineke/indent-blankline.nvim",
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/nvim-lualine/lualine.nvim",
	"https://github.com/nvim-neo-tree/neo-tree.nvim",
	"https://github.com/nvim-telescope/telescope-fzf-native.nvim",
	"https://github.com/nvim-telescope/telescope-live-grep-args.nvim",
	"https://github.com/nvim-telescope/telescope.nvim",
	"https://github.com/nvim-tree/nvim-web-devicons",
	"https://github.com/nvim-treesitter/nvim-treesitter-context",
	"https://github.com/scottmckendry/cyberdream.nvim",
	"https://github.com/stevearc/conform.nvim",
	"https://github.com/tronikelis/conflict-marker.nvim",
	"https://github.com/tronikelis/ts-autotag.nvim",
	"https://github.com/williamboman/mason.nvim",
	"https://github.com/windwp/nvim-autopairs",
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
})

-- mason
require("mason").setup()

require("lualine").setup({
	sections = {
		lualine_c = { { "filename", path = 1 } },
		lualine_b = { { "b:gitsigns_head", icon = "" } },
	},
})

-- LSP + cmp
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local function setupServer(server_name)
	vim.lsp.config(server_name, { capabilities = capabilities })
	vim.lsp.enable(server_name)
end
setupServer("ts_ls")
setupServer("tailwindcss")
setupServer("eslint")
setupServer("jsonls")

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local opts = { buffer = args.buf }
		vim.keymap.set("n", "gr", require("telescope.builtin").lsp_references, opts)
		vim.keymap.set("n", "gd", require("telescope.builtin").lsp_definitions, opts)
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
		vim.keymap.set("n", "<leader>@", require("telescope.builtin").lsp_document_symbols, opts)
		vim.keymap.set("n", "<leader>a", vim.lsp.buf.code_action)
		vim.keymap.set("n", "ge", vim.diagnostic.open_float)
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
		vim.keymap.set("n", "gh", vim.lsp.buf.hover)
	end,
})

local cmp = require("cmp")
cmp.setup({
	mapping = {
		["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
		["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
		["<Tab>"] = cmp.mapping.confirm({ select = true }),
		["<C-space>"] = cmp.mapping.complete(),
	},
	sources = {
		{ name = "nvim_lsp" },
		{ name = "nvim_lsp_signature_help" },
	},
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
})

-- gitsigns
require("gitsigns").setup({
	current_line_blame = true,
	gh = true,
})
vim.keymap.set("n", "<leader>gb", function()
	local file = vim.fn.expand("%:p")
	local lnum = vim.fn.line(".")
	if file == "" then
		vim.notify("No file", vim.log.levels.WARN)
		return
	end
	local blame = vim.fn.system({ "git", "blame", "-L", ("%d,%d"):format(lnum, lnum), "--porcelain", file })
	if vim.v.shell_error ~= 0 then
		vim.notify("git blame failed:\n" .. blame, vim.log.levels.ERROR)
		return
	end
	local sha = blame:match("^(%x+)")
	if not sha or sha:match("^0+$") then
		vim.notify("Could not parse sha", vim.log.levels.ERROR)
		return
	end
	vim.notify("Opening " .. sha)
	vim.fn.jobstart({ "gh", "browse", sha }, {
		detach = true,
		on_stderr = function(_, data)
			if data and table.concat(data, ""):match("%S") then
				vim.schedule(function()
					vim.notify("gh error:\n" .. table.concat(data, "\n"), vim.log.levels.ERROR)
				end)
			end
		end,
	})
end, { desc = "Open blame commit in GitHub" })

-- treesitter
require("nvim-treesitter").setup()

vim.api.nvim_create_autocmd("FileType", {
	callback = function(ev)
		if pcall(vim.treesitter.start, ev.buf) then
			vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end
	end,
})

require("treesitter-context").setup({ max_lines = 3, multiline_threshold = 1 })

-- telescope
local actions = require("telescope.actions")
require("telescope").setup({
	pickers = {
		find_files = { hidden = true },
		oldfiles = { cwd_only = true },
	},
	defaults = {
		file_ignore_patterns = { ".git/" },
		mappings = { i = { ["<esc>"] = actions.close } },
	},
})
require("telescope").load_extension("fzf")
require("telescope").load_extension("live_grep_args")
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>p", builtin.find_files)
vim.keymap.set("n", "<leader>ht", builtin.help_tags)
vim.keymap.set("n", "<leader>o", builtin.oldfiles)
vim.keymap.set("n", "<leader><s-f>", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>")
vim.keymap.set("n", "<leader>sx", builtin.resume, { noremap = true, silent = true, desc = "Resume" })

-- neo-tree
local events = require("neo-tree.events")
local function on_file_remove(args)
	local ts_clients = vim.lsp.get_clients({ name = "ts_ls" })
	for _, ts_client in ipairs(ts_clients) do
		ts_client.request("workspace/executeCommand", {
			command = "_typescript.applyRenameFile",
			arguments = {
				{
					sourceUri = vim.uri_from_fname(args.source),
					targetUri = vim.uri_from_fname(args.destination),
				},
			},
		})
	end
end
require("neo-tree").setup({
	filesystem = {
		filtered_items = { hide_dotfiles = false, hide_gitignored = false, visible = true },
		follow_current_file = { enabled = true, leave_dirs_open = false },
		use_libuv_file_watcher = true,
	},
	event_handlers = {
		{
			event = events.NEO_TREE_BUFFER_ENTER,
			handler = function()
				vim.wo.number = true
				vim.wo.relativenumber = true
			end,
		},
		{ event = events.FILE_MOVED, handler = on_file_remove },
		{ event = events.FILE_RENAMED, handler = on_file_remove },
	},
})
vim.keymap.set("n", "<leader>b", ":Neotree toggle<CR>")
vim.api.nvim_create_autocmd("BufLeave", {
	pattern = { "*lazygit*" },
	group = vim.api.nvim_create_augroup("neovim_update_tree", { clear = true }),
	callback = function()
		require("neo-tree.sources.filesystem.commands").refresh(
			require("neo-tree.sources.manager").get_state("filesystem")
		)
	end,
})

-- autopairs
require("nvim-autopairs").setup({ disable_filetype = { "TelescopePrompt", "vim" }, check_ts = true })

-- conform
require("conform").setup({
	format_on_save = { timeout_ms = 2500, lsp_format = "fallback" },
	formatters_by_ft = {
		lua = { "stylua" },
		javascript = { "prettier" },
		typescript = { "prettier" },
		typescriptreact = { "prettier" },
	},
})

-- indent-blankline
require("ibl").setup({ scope = { show_start = false, show_end = false } })

-- ts-autotag
require("ts-autotag").setup({ auto_rename = { enabled = true } })

-- lualine
require("lualine").setup()

-- conflict-marker
require("conflict-marker").setup()

-- lazygit
vim.keymap.set("n", "<leader><S-g>", "<cmd>LazyGit<cr>", { desc = "Open lazy git" })

-- copilot
vim.keymap.set("i", "<leader><Tab>", 'copilot#Accept("")', {
	expr = true,
	silent = true,
	replace_keycodes = false,
	desc = "Accept Copilot suggestion",
})

-- neominimap
vim.keymap.set("n", "<leader>m", ":Neominimap Toggle<CR>")

-- neominimap highlight overrides (must come after colorscheme)
vim.cmd([[
    colorscheme cyberdream
	highlight NeominimapGitAddLine guifg=#00ff00 guibg=#004d00
	highlight NeominimapGitChangeLine guifg=#ffff00 guibg=#4d4d00
	highlight NeominimapGitDeleteLine guifg=#ff3333 guibg=#4d0000
	highlight NeominimapGitAddIcon guifg=#00ff00 guibg=NONE
	highlight NeominimapGitChangeIcon guifg=#ffff00 guibg=NONE
	highlight NeominimapGitDeleteIcon guifg=#ff3333 guibg=NONE
]])
