--[[
=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================
========                                    .-----.          ========
========         .----------------------.   | === |          ========
========         |.-""""""""""""""""""-.|   |-----|          ========
========         ||                    ||   | === |          ========
========         ||   KICKSTART.NVIM   ||   |-----|          ========
========         ||                    ||   | === |          ========
========         ||                    ||   |-----|          ========
========         ||:Tutor              ||   |:::::|          ========
========         `"")----------------(""`   ___________      ========
========        /::::::::::|  |::::::::::\  \ no mouse \     ========
========       /:::========|  |==hjkl==:::\  \ required \    ========
========      '""""""""""""'  '""""""""""""'  '""""""""""'   ========
========                                                     ========
=====================================================================
=====================================================================
--]]

-- ============================================================
-- SECTION 1: FOUNDATION
-- ============================================================
do
	vim.loader.enable()

	vim.g.mapleader = " "
	vim.g.maplocalleader = " "
	vim.g.have_nerd_font = true

	-- [[ Options ]]
	vim.o.number = true
	vim.o.relativenumber = true
	vim.o.mouse = "a"
	vim.o.showmode = false
	vim.o.breakindent = true
	vim.o.undofile = true
	vim.o.ignorecase = true
	vim.o.smartcase = true
	vim.o.signcolumn = "yes"
	vim.o.updatetime = 250
	vim.o.timeoutlen = 300
	vim.o.splitright = true
	vim.o.splitbelow = true
	vim.o.list = true
	vim.o.inccommand = "split"
	vim.o.cursorline = true
	vim.o.scrolloff = 10
	vim.o.confirm = true
	vim.o.hlsearch = true
	vim.o.autowrite = true
	vim.o.tabstop = 4

	vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

	-- Clipboard: sync con OS (delayed para no ralentizar el arranque)
	vim.schedule(function()
		vim.o.clipboard = "unnamedplus"
	end)

	-- [[ Keymaps básicos ]]
	vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
	vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

	-- Diagnósticos
	vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic" })
	vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic" })
	vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
	vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

	-- Navegación de ventanas
	vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
	vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
	vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
	vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

	-- Splits
	vim.keymap.set("n", "<leader>ssh", "<cmd>split<CR>", { desc = "Split horizontal" })
	vim.keymap.set("n", "<leader>ssv", "<cmd>vsplit<CR>", { desc = "Split vertical" })

	-- Guardar / salir
	vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Save" })
	vim.keymap.set("n", "<leader>W", "<cmd>wq<CR>", { desc = "Save and quit" })
	vim.keymap.set("n", "<leader>Q", "<cmd>q!<CR>", { desc = "Quit without saving" })

	-- Neo-tree
	vim.keymap.set("n", "<leader>nt", "<cmd>Neotree<CR>", { desc = "Toggle [N]vim [T]ree" })
	vim.keymap.set("n", "<leader>nf", "<cmd>Neotree reveal<CR>", { desc = "[N]vim tree reveal [F]ile" })
	vim.keymap.set("n", "<leader>nb", "<cmd>Neotree buffer<CR>", { desc = "[N]vim tree [B]uffer" })

	-- Teclas de flechas desactivadas en normal mode
	vim.keymap.set("n", "<left>", '<cmd>echo "Use h to move!!"<CR>')
	vim.keymap.set("n", "<right>", '<cmd>echo "Use l to move!!"<CR>')
	vim.keymap.set("n", "<up>", '<cmd>echo "Use k to move!!"<CR>')
	vim.keymap.set("n", "<down>", '<cmd>echo "Use j to move!!"<CR>')

	-- Diagnóstico (configuración visual)
	vim.diagnostic.config({
		update_in_insert = false,
		severity_sort = true,
		float = { border = "rounded", source = "if_many" },
		underline = { severity = { min = vim.diagnostic.severity.WARN } },
		virtual_text = true,
		virtual_lines = false,
	})

	-- [[ Autocommands básicos ]]
	vim.api.nvim_create_autocmd("TextYankPost", {
		desc = "Highlight when yanking (copying) text",
		group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
		callback = function()
			vim.hl.on_yank()
		end,
	})

	vim.api.nvim_create_autocmd("FocusLost", {
		desc = "Autosave files when focus is lost",
		group = vim.api.nvim_create_augroup("kickstart-autosave", { clear = true }),
		pattern = "*",
		callback = function()
			vim.cmd("silent! wa")
		end,
	})

	-- Soporte para Godot Engine (abre el socket si hay project.godot)
	local gdproject = io.open(vim.fn.getcwd() .. "/project.godot", "r")
	if gdproject then
		io.close(gdproject)
		vim.fn.serverstart("./godothost")
	end
end

-- ============================================================
-- SECTION 2: PLUGIN MANAGER (vim.pack) + BUILD HOOKS
-- ============================================================
do
	-- vim.pack es el gestor de plugins built-in desde Neovim 0.11+.
	-- Para actualizar plugins: :lua vim.pack.update()
	-- Para ver estado sin descargar: :lua vim.pack.update(nil, { offline = true })

	local function run_build(name, cmd, cwd)
		local result = vim.system(cmd, { cwd = cwd }):wait()
		if result.code ~= 0 then
			local stderr = result.stderr or ""
			local stdout = result.stdout or ""
			local output = stderr ~= "" and stderr or stdout
			if output == "" then
				output = "No output from build command."
			end
			vim.notify(("Build failed for %s:\n%s"):format(name, output), vim.log.levels.ERROR)
		end
	end

	vim.api.nvim_create_autocmd("PackChanged", {
		callback = function(ev)
			local name = ev.data.spec.name
			local kind = ev.data.kind
			if kind ~= "install" and kind ~= "update" then
				return
			end

			if name == "telescope-fzf-native.nvim" and vim.fn.executable("make") == 1 then
				run_build(name, { "make" }, ev.data.path)
				return
			end

			if name == "LuaSnip" then
				if vim.fn.has("win32") ~= 1 and vim.fn.executable("make") == 1 then
					run_build(name, { "make", "install_jsregexp" }, ev.data.path)
				end
				return
			end

			if name == "nvim-treesitter" then
				if not ev.data.active then
					vim.cmd.packadd("nvim-treesitter")
				end
				vim.cmd("TSUpdate")
				return
			end
		end,
	})
end

-- Helper para URLs de GitHub
---@param repo string
---@return string
local function gh(repo)
	return "https://github.com/" .. repo
end

-- ============================================================
-- SECTION 3: UI / CORE UX PLUGINS
-- ============================================================
do
	-- Detecta y aplica indentación automáticamente
	vim.pack.add({ gh("NMAC427/guess-indent.nvim") })
	require("guess-indent").setup({})

	-- Iconos (requiere Nerd Font)
	if vim.g.have_nerd_font then
		vim.pack.add({ gh("nvim-tree/nvim-web-devicons") })
	end

	-- Git signs en el gutter
	vim.pack.add({ gh("lewis6991/gitsigns.nvim") })
	require("gitsigns").setup({
		signs = {
			add = { text = "▎" },
			change = { text = "▎" },
			delete = { text = "_" },
			topdelete = { text = "‾" },
			changedelete = { text = "~" },
		},
		on_attach = function(bufnr)
			local gs = require("gitsigns")
			vim.keymap.set("n", "<leader>gp", gs.preview_hunk, { buffer = bufnr, desc = "Preview [G]it [P]atch" })
			vim.keymap.set(
				"n",
				"<leader>gtc",
				gs.toggle_current_line_blame,
				{ buffer = bufnr, desc = "[G]it [T]oggle [C]urrent line blame" }
			)
		end,
	})

	-- vim-fugitive (Git desde la línea de comandos de Neovim)
	vim.pack.add({ gh("tpope/vim-fugitive") })

	-- which-key: muestra keybinds pendientes
	vim.pack.add({ gh("folke/which-key.nvim") })
	require("which-key").setup({
		delay = 0,
		icons = { mappings = vim.g.have_nerd_font },
		spec = {
			{ "<leader>c", group = "[C]ode" },
			{ "<leader>d", group = "[D]ocument" },
			{ "<leader>g", group = "[G]it" },
			{ "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
			{ "<leader>n", group = "[N]eo-tree" },
			{ "<leader>r", group = "[R]ename" },
			{ "<leader>s", group = "[S]earch", mode = { "n", "v" } },
			{ "<leader>ss", group = "[S]plit" },
			{ "<leader>t", group = "[T]oggle" },
			{ "<leader>tt", group = "[T]est" },
			{ "<leader>w", group = "[W]orkspace / Save" },
			{ "gr", group = "LSP Actions" },
		},
	})

	-- ── Temas de color ────────────────────────────────────────────
	vim.pack.add({ gh("folke/tokyonight.nvim") })
	vim.pack.add({ gh("Everblush/nvim") }) -- el que usas actualmente
	vim.pack.add({ gh("EdenEast/nightfox.nvim") })
	vim.pack.add({ gh("navarasu/onedark.nvim") })
	vim.pack.add({ gh("catppuccin/nvim") })
	vim.pack.add({ gh("rebelot/kanagawa.nvim") })
	vim.pack.add({ gh("bluz71/vim-moonfly-colors") })
	vim.pack.add({ gh("savq/melange-nvim") })
	vim.pack.add({ gh("scottmckendry/cyberdream.nvim") })
	vim.pack.add({ gh("dasupradyumna/midnight.nvim") })
	vim.pack.add({ gh("zootedb0t/citruszest.nvim") })
	vim.pack.add({ gh("uloco/bluloco.nvim") }) -- depende de lush
	vim.pack.add({ gh("rktjmp/lush.nvim") }) -- dependencia de bluloco

	-- Colorscheme activo
	vim.cmd.hi("Comment gui=none")
	vim.cmd.colorscheme("everblush")

	-- todo-comments: resalta TODO, FIXME, NOTE, etc.
	vim.pack.add({ gh("folke/todo-comments.nvim") })
	require("todo-comments").setup({ signs = false })

	-- mini.nvim: conjunto de módulos pequeños
	vim.pack.add({ gh("nvim-mini/mini.nvim") })
	require("mini.ai").setup({
		mappings = { around_next = "aa", inside_next = "ii" },
		n_lines = 500,
	})
	require("mini.surround").setup()
	require("mini.comment").setup()
	require("mini.bracketed").setup()
	require("mini.hipatterns").setup()

	local statusline = require("mini.statusline")
	statusline.setup({ use_icons = vim.g.have_nerd_font })
	---@diagnostic disable-next-line: duplicate-set-field
	statusline.section_location = function()
		return "%2l:%-2v"
	end

	-- Barbar: barra de tabs/buffers
	vim.pack.add({ gh("romgrk/barbar.nvim") })
	vim.g.barbar_auto_setup = false
	require("barbar").setup({})

	-- Alpha: pantalla de inicio
	vim.pack.add({ gh("goolord/alpha-nvim") })
	require("alpha").setup(require("alpha.themes.dashboard").config)

	-- suda.vim: editar ficheros con sudo
	vim.pack.add({ gh("lambdalisue/suda.vim") })
	vim.g.suda_smart_edit = 1

	-- vim-devicons (iconos legacy para plugins que no usan nvim-web-devicons)
	vim.pack.add({ gh("ryanoasis/vim-devicons") })
end

-- ============================================================
-- SECTION 4: SEARCH & NAVIGATION
-- ============================================================
do
	local telescope_plugins = {
		gh("nvim-lua/plenary.nvim"),
		gh("nvim-telescope/telescope.nvim"),
		gh("nvim-telescope/telescope-ui-select.nvim"),
	}
	if vim.fn.executable("make") == 1 then
		table.insert(telescope_plugins, gh("nvim-telescope/telescope-fzf-native.nvim"))
	end
	vim.pack.add(telescope_plugins)

	require("telescope").setup({
		extensions = {
			["ui-select"] = { require("telescope.themes").get_dropdown() },
		},
	})
	pcall(require("telescope").load_extension, "fzf")
	pcall(require("telescope").load_extension, "ui-select")

	local builtin = require("telescope.builtin")
	vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
	vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
	vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
	vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
	vim.keymap.set({ "n", "v" }, "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
	vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
	vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
	vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
	vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = "[S]earch Recent Files" })
	vim.keymap.set("n", "<leader>sc", builtin.commands, { desc = "[S]earch [C]ommands" })
	vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

	vim.keymap.set("n", "<leader>/", function()
		builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
			winblend = 10,
			previewer = false,
		}))
	end, { desc = "[/] Fuzzily search in current buffer" })

	vim.keymap.set("n", "<leader>s/", function()
		builtin.live_grep({ grep_open_files = true, prompt_title = "Live Grep in Open Files" })
	end, { desc = "[S]earch [/] in Open Files" })

	vim.keymap.set("n", "<leader>sn", function()
		builtin.find_files({ cwd = vim.fn.stdpath("config") })
	end, { desc = "[S]earch [N]eovim files" })

	-- LSP pickers vía Telescope (se asignan al adjuntar el LSP)
	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("telescope-lsp-attach", { clear = true }),
		callback = function(event)
			local buf = event.buf
			vim.keymap.set("n", "grr", builtin.lsp_references, { buffer = buf, desc = "[G]oto [R]eferences" })
			vim.keymap.set("n", "gri", builtin.lsp_implementations, { buffer = buf, desc = "[G]oto [I]mplementation" })
			vim.keymap.set("n", "grd", builtin.lsp_definitions, { buffer = buf, desc = "[G]oto [D]efinition" })
			vim.keymap.set("n", "gO", builtin.lsp_document_symbols, { buffer = buf, desc = "Open Document Symbols" })
			vim.keymap.set(
				"n",
				"gW",
				builtin.lsp_dynamic_workspace_symbols,
				{ buffer = buf, desc = "Open Workspace Symbols" }
			)
			vim.keymap.set(
				"n",
				"grt",
				builtin.lsp_type_definitions,
				{ buffer = buf, desc = "[G]oto [T]ype Definition" }
			)
		end,
	})
end

-- ============================================================
-- SECTION 5: LSP
-- ============================================================
do
	-- fidget: notificaciones de estado del LSP
	vim.pack.add({ gh("j-hui/fidget.nvim") })
	require("fidget").setup({})

	vim.pack.add({
		gh("neovim/nvim-lspconfig"),
		gh("mason-org/mason.nvim"),
		gh("mason-org/mason-lspconfig.nvim"),
		gh("WhoIsSethDaniel/mason-tool-installer.nvim"),
	})

	require("mason").setup({})

	-- Keymaps LSP (se aplican al adjuntar)
	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
		callback = function(event)
			local map = function(keys, func, desc, mode)
				mode = mode or "n"
				vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
			end

			map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
			map("gra", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })
			map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
			map("K", vim.lsp.buf.hover, "Hover Documentation")
			map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
			map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

			local client = vim.lsp.get_client_by_id(event.data.client_id)

			-- Highlight de referencias al descansar el cursor
			if client and client:supports_method("textDocument/documentHighlight", event.buf) then
				local hl_group = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
				vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
					buffer = event.buf,
					group = hl_group,
					callback = vim.lsp.buf.document_highlight,
				})
				vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
					buffer = event.buf,
					group = hl_group,
					callback = vim.lsp.buf.clear_references,
				})
				vim.api.nvim_create_autocmd("LspDetach", {
					group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
					callback = function(ev2)
						vim.lsp.buf.clear_references()
						vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = ev2.buf })
					end,
				})
			end

			-- Inlay hints
			if client and client:supports_method("textDocument/inlayHint", event.buf) then
				map("<leader>th", function()
					vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
				end, "[T]oggle Inlay [H]ints")
			end
		end,
	})

	-- Servidores LSP a instalar y configurar
	---@type table<string, vim.lsp.Config>
	local servers = {
		-- Lenguajes de uso general
		pyright = {},
		-- tsserver  = {},  -- descomenta para TypeScript/JavaScript
		-- gopls     = {},
		-- rust_analyzer = {},
		-- clangd    = {},

		-- GDScript (Godot) — se conecta al editor vía socket, no a través de Mason
		-- gdscript se configura manualmente más abajo

		-- Lua
		stylua = {},
		lua_ls = {
			on_init = function(client)
				client.server_capabilities.documentFormattingProvider = false
				if client.workspace_folders then
					local path = client.workspace_folders[1].name
					if
						path ~= vim.fn.stdpath("config")
						and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
					then
						return
					end
				end
				client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua or {}, {
					runtime = { version = "LuaJIT" },
					workspace = {
						checkThirdParty = false,
						library = vim.tbl_extend("force", vim.api.nvim_get_runtime_file("", true), {
							"${3rd}/luv/library",
							"${3rd}/busted/library",
						}),
					},
				})
			end,
			settings = {
				Lua = {
					format = { enable = false },
					completion = { callSnippet = "Replace" },
				},
			},
		},
	}

	local ensure_installed = vim.tbl_keys(servers or {})
	vim.list_extend(ensure_installed, { "stylua" })
	require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

	-- GDScript: se conecta al socket que lanza Godot, no se instala vía Mason
	vim.lsp.config("gdscript", {
		cmd = vim.fn.has("win32") == 1 and { "ncat", "localhost", "6005" } or { "nc", "localhost", "6005" },
		filetypes = { "gd", "gdscript", "gdscript3" },
	})
	vim.lsp.enable("gdscript")

	-- Resto de servidores vía vim.lsp.config / vim.lsp.enable
	for name, server in pairs(servers) do
		if name ~= "stylua" then -- stylua es un formatter, no un LSP server
			vim.lsp.config(name, server)
			vim.lsp.enable(name)
		end
	end
end

-- ============================================================
-- SECTION 6: FORMATTING (conform.nvim)
-- ============================================================
do
	vim.pack.add({ gh("stevearc/conform.nvim") })
	require("conform").setup({
		notify_on_error = false,
		format_on_save = function(bufnr)
			local enabled = { lua = true }
			if enabled[vim.bo[bufnr].filetype] then
				return { timeout_ms = 500 }
			end
		end,
		default_format_opts = { lsp_format = "fallback" },
		formatters_by_ft = {
			lua = { "stylua" },
			-- python = { 'isort', 'black' },
			-- javascript = { 'prettierd', 'prettier', stop_after_first = true },
		},
	})

	vim.keymap.set({ "n", "v" }, "<leader>f", function()
		require("conform").format({ async = true })
	end, { desc = "[F]ormat buffer" })
end

-- ============================================================
-- SECTION 7: AUTOCOMPLETE & SNIPPETS
-- ============================================================
do
	-- LuaSnip: motor de snippets
	vim.pack.add({ { src = gh("L3MON4D3/LuaSnip"), version = vim.version.range("2.*") } })
	require("luasnip").setup({})

	-- friendly-snippets: colección de snippets listos para usar
	vim.pack.add({ gh("rafamadriz/friendly-snippets") })
	require("luasnip.loaders.from_vscode").lazy_load()

	-- blink.cmp: motor de autocompletado (reemplaza nvim-cmp)
	vim.pack.add({ { src = gh("saghen/blink.cmp"), version = vim.version.range("1.*") } })
	require("blink.cmp").setup({
		keymap = { preset = "default" },
		appearance = { nerd_font_variant = "mono" },
		completion = {
			documentation = { auto_show = false, auto_show_delay_ms = 500 },
		},
		sources = { default = { "lsp", "path", "snippets" } },
		snippets = { preset = "luasnip" },
		fuzzy = { implementation = "lua" },
		signature = { enabled = true },
	})
end

-- ============================================================
-- SECTION 8: TREESITTER
-- NOTA: tree-sitter-cli debe estar instalado manualmente (ya lo tienes).
-- ============================================================
do
	vim.pack.add({ { src = gh("nvim-treesitter/nvim-treesitter"), version = "main" } })

	local parsers = {
		"bash",
		"c",
		"diff",
		"html",
		"lua",
		"luadoc",
		"markdown",
		"markdown_inline",
		"query",
		"vim",
		"vimdoc",
		-- Godot
		"gdscript",
		"godot_resource",
		"gdshader",
		-- Otros lenguajes que usas
		"python",
		"typescript",
		"javascript",
	}
	require("nvim-treesitter").install(parsers)

	---@param buf integer
	---@param language string
	local function treesitter_try_attach(buf, language)
		if not vim.treesitter.language.add(language) then
			return
		end
		vim.treesitter.start(buf, language)
		local has_indent = vim.treesitter.query.get(language, "indents") ~= nil
		if has_indent then
			vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end
	end

	local available_parsers = require("nvim-treesitter").get_available()
	vim.api.nvim_create_autocmd("FileType", {
		callback = function(args)
			local buf, filetype = args.buf, args.match
			local language = vim.treesitter.language.get_lang(filetype)
			if not language then
				return
			end
			local installed = require("nvim-treesitter").get_installed("parsers")
			if vim.tbl_contains(installed, language) then
				treesitter_try_attach(buf, language)
			elseif vim.tbl_contains(available_parsers, language) then
				require("nvim-treesitter").install(language):await(function()
					treesitter_try_attach(buf, language)
				end)
			else
				treesitter_try_attach(buf, language)
			end
		end,
	})
end

-- ============================================================
-- SECTION 9: EDITOR TOOLS
-- ============================================================
do
	-- autopairs: cierra (), {}, [], "", etc.
	vim.pack.add({ gh("windwp/nvim-autopairs") })
	require("nvim-autopairs").setup({})

	-- Comment.nvim: comentar con gc
	vim.pack.add({ gh("numToStr/Comment.nvim") })
	require("Comment").setup({})

	-- vim-sleuth: detecta tabstop/shiftwidth automáticamente
	vim.pack.add({ gh("tpope/vim-sleuth") })

	-- vim-godot: mejor indentación para GDScript
	vim.pack.add({ gh("habamax/vim-godot") })

	-- nvim-tmux-navigation: navegar entre panes de Neovim y tmux con C-hjkl
	vim.pack.add({ gh("alexghergh/nvim-tmux-navigation") })
	local nvim_tmux_nav = require("nvim-tmux-navigation")
	nvim_tmux_nav.setup({ disable_when_zoomed = true })
	-- NOTA: estos mapas sobreescriben los C-hjkl de ventanas de Neovim.
	-- Si no usas tmux, elimina este bloque y déjalos como están en Section 1.
	vim.keymap.set("n", "<C-h>", nvim_tmux_nav.NvimTmuxNavigateLeft)
	vim.keymap.set("n", "<C-j>", nvim_tmux_nav.NvimTmuxNavigateDown)
	vim.keymap.set("n", "<C-k>", nvim_tmux_nav.NvimTmuxNavigateUp)
	vim.keymap.set("n", "<C-l>", nvim_tmux_nav.NvimTmuxNavigateRight)
	vim.keymap.set("n", "<C-\\>", nvim_tmux_nav.NvimTmuxNavigateLastActive)
	vim.keymap.set("n", "<C-Space>", nvim_tmux_nav.NvimTmuxNavigateNext)
end

-- ============================================================
-- SECTION 10: LINTING (nvim-lint)
-- ============================================================
do
	vim.pack.add({ gh("mfussenegger/nvim-lint") })
	require("lint").linters_by_ft = {
		python = { "flake8" },
		-- lua = { "luacheck" },
		markdown = { "markdownlint" },
		sh = { "shellcheck" },
		yaml = { "yamllint" },
		json = { "jsonlint" },
		typescript = { "eslint" },
		javascript = { "eslint" },
		go = { "golangci_lint" },
		rust = { "cargo" },
	}

	-- Lanzar el linter al guardar y al abrir un buffer
	vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
		callback = function()
			require("lint").try_lint()
		end,
	})
end

-- ============================================================
-- SECTION 11: DEBUGGING (nvim-dap)
-- ============================================================
do
	vim.pack.add({ gh("mfussenegger/nvim-dap") })
	vim.pack.add({ gh("theHamsta/nvim-dap-virtual-text") })
	vim.pack.add({ gh("nvim-neotest/nvim-nio") })
	vim.pack.add({ gh("rcarriga/nvim-dap-ui") })
	-- NOTA: DAPInstall.nvim está abandonado. Para instalar adaptadores
	-- usa mason-nvim-dap.nvim o configúralos manualmente en tu dap config.
	-- vim.pack.add { gh 'jay-babu/mason-nvim-dap.nvim' }

	require("nvim-dap-virtual-text").setup({})

	local dap = require("dap")
	local dapui = require("dapui")
	dapui.setup({})

	dap.listeners.after.event_initialized["dapui_config"] = dapui.open
	dap.listeners.before.event_terminated["dapui_config"] = dapui.close
	dap.listeners.before.event_exited["dapui_config"] = dapui.close

	vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "[D]ebug toggle [B]reakpoint" })
	vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "[D]ebug [C]ontinue" })
	vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "[D]ebug Step [I]nto" })
	vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "[D]ebug Step [O]ver" })
	vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "[D]ebug Step [O]ut" })
	vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "[D]ebug [U]I" })
end

-- ============================================================
-- SECTION 12: TESTING (vim-test)
-- ============================================================
do
	vim.pack.add({ gh("preservim/vimux") })
	vim.pack.add({ gh("vim-test/vim-test") })

	vim.cmd("let test#strategy = 'vimux'")

	vim.keymap.set("n", "<leader>ttn", "<cmd>TestNearest<CR>", { desc = "[T]est [N]earest" })
	vim.keymap.set("n", "<leader>ttf", "<cmd>TestFile<CR>", { desc = "[T]est [F]ile" })
	vim.keymap.set("n", "<leader>tta", "<cmd>TestSuite<CR>", { desc = "[T]est [A]ll suite" })
	vim.keymap.set("n", "<leader>ttl", "<cmd>TestLast<CR>", { desc = "[T]est [L]ast" })
	vim.keymap.set("n", "<leader>ttv", "<cmd>TestVisit<CR>", { desc = "[T]est [V]isit" })
end

-- ============================================================
-- SECTION 13: FILE EXPLORER (Neo-tree v3.x)
-- Se usa la rama v3.x, la más estable a fecha de 2026.
-- ============================================================
do
	vim.pack.add({ gh("MunifTanjim/nui.nvim") })
	vim.pack.add({ gh("nvim-neo-tree/neo-tree.nvim") })

	require("neo-tree").setup({
		close_if_last_window = true,
		enable_git_status = true,
		enable_diagnostics = true,
		window = { width = 30 },
		event_handlers = {
			{
				event = "file_opened",
				handler = function(_)
					require("neo-tree.command").execute({ action = "close" })
				end,
			},
		},
		buffers = {
			follow_current_file = { enable = true },
		},
		filesystem = {
			follow_current_file = { enable = true },
			filtered_items = {
				hide_dotfiles = false,
				hide_gitignored = false,
				hide_by_name = { "node_modules" },
				never_show = { ".DS_Store", "thumbs.db" },
			},
		},
	})
end

-- ============================================================
-- FIN
-- ============================================================
-- vim: ts=2 sts=2 sw=2 et
