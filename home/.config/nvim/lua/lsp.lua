-- LSP configs
vim.lsp.config["lua-language-server"] = {
    cmd = { vim.fn.stdpath("data") .. "/mason/bin/lua-language-server" },
    root_markers = { '.luarc.json', '.luarc.jsonc' },
    filetypes = { "lua" },
    settings = {
        Lua = {
            runtime = {
                version = 'LuaJIT',
            }
        }
    }
}

vim.lsp.config["clangd"] = {
    cmd = { vim.fn.stdpath("data") .. "/mason/bin/clangd" },
    filetypes = { "c", "cpp", "objc", "objcpp" },
    root_markers = { "compile_commands.json", "compile_flags.txt", ".git" },
}

vim.lsp.config["yamlls"] = {
    cmd = { "yaml-language-server", "--stdio" },
    filetypes = { "yaml", "yml" },
    root_markers = { ".git" },
    settings = {
        yaml = {
            format = { enable = true },
            validate = true,
            schemas = {
                kubernetes = "*.yaml",
            },
            schemaStore = {
                enable = false,
            },
        },
    },
}

vim.lsp.config["pyright"] = {
    cmd = { vim.fn.stdpath("data") .. "/mason/bin/pyright-langserver", "--stdio" },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
    settings = {
        python = {
            analysis = {
                autoImportCompletions = true,
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "workspace",
                typeCheckingMode = "basic",
            },
        },
    },
}

vim.lsp.config["marksman"] = {
    cmd = { "marksman" },
    filetypes = { "markdown", "markdown.mdx" },
    root_markers = { ".git", "package.json", "package-lock.json" },
}

vim.lsp.enable({"lua-language-server", "clangd", "pyright", "yamlls", "marksman"})

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client and client:supports_method('textDocument/completion') then
            -- yamlls triggers autotrigger spam and freezes — disable for it
            if client.name ~= 'yamlls' then
                vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
            end
        end
    end,
})
