return {
	{
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      { 'j-hui/fidget.nvim', opts = {} },
    },
	
	config = function()
	vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true })
	
	-- Define an autocommand within the group
        vim.api.nvim_create_autocmd('LspAttach', {
            group = 'kickstart-lsp-attach',
            callback = function(event)
			local map = function(keys, func, desc)
				vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
			  end

			map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
			map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
			map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
			
			map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
			map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
			map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
			
			map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
			map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
			map('K', vim.lsp.buf.hover, 'Hover Documentation')
			
			map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
			
			local client = vim.lsp.get_client_by_id(event.data.client_id)
			if client and client.server_capabilities.documentHighlightProvider then
				vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
				  buffer = event.buf,
				  callback = vim.lsp.buf.document_highlight,
				})

				vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
				  buffer = event.buf,
				  callback = vim.lsp.buf.clear_references,
				})
			end
		end,
	})
		
	local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())
	  
	local servers = {
        clangd = {},
		csharp_ls = {},
		cssls = {},
		jsonls = {},
		intelephense = {},
		sqlls = {},
		tailwindcss = {},
		zls = {},
        gopls = {},
        pyright = {},
        rust_analyzer = {},
        -- :help lspconfig-all` for a list of all the pre-configured LSPs
        tsserver = {},
		
        lua_ls = {
          -- cmd = {...},
          -- filetypes { ...},
          -- capabilities = {},
          settings = {
            Lua = {
              runtime = { version = 'LuaJIT' },
              workspace = {
                checkThirdParty = false,
                library = {
                  '${3rd}/luv/library',
                  unpack(vim.api.nvim_get_runtime_file('', true)),
                },
                -- If lua_ls is really slow on your computer, you can try this instead:
                -- library = { vim.env.VIMRUNTIME },
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
      }

	require('mason').setup()

      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format lua code
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            require('lspconfig')[server_name].setup {
              cmd = server.cmd,
              settings = server.settings,
              filetypes = server.filetypes,
              -- This handles overriding only values explicitly passed
              -- by the server configuration above. Useful when disabling
              -- certain features of an LSP (for example, turning off formatting for tsserver)
              capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {}),
            }
          end,
        },
      }
    end,
}
}