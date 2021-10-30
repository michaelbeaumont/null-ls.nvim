local methods = require("null-ls.methods")
local c = require("null-ls.config")
local u = require("null-ls.utils")

local api = vim.api

local M = {}

function M.setup()
    local configs = require("lspconfig/configs")
    local util = require("lspconfig/util")

    local config_def = {
        cmd = { "nvim" },
        name = "null-ls",
        root_dir = function(fname)
            return util.root_pattern("Makefile", ".git")(fname) or util.path.dirname(fname)
        end,
        flags = { debounce_text_changes = c.get().debounce },
        filetypes = c.get()._filetypes,
        autostart = false,
    }

    configs["null-ls"] = {
        default_config = config_def,
    }

    -- listen on FileType and try attaching
    vim.cmd([[
      augroup NullLs
        autocmd!
        autocmd FileType * unsilent lua require("null-ls.lspconfig").try_add()
      augroup end
    ]])
end

-- update filetypes shown in :LspInfo
function M.on_register_filetypes()
    local config = require("lspconfig")["null-ls"]
    if not config then
        return
    end

    config.filetypes = c.get()._filetypes
end

-- try attaching to existing buffers and (if applicable) send a didChange notification to refresh diagnostics
function M.on_register_source(source_methods)
    -- lspconfig hasn't been set up yet, meaning the source was registered normally (i.e. not dynamically)
    if not require("lspconfig")["null-ls"] then
        return
    end

    local client = u.get_client()
    local is_diagnostic_source = vim.tbl_contains(source_methods, methods.internal.DIAGNOSTICS)
    local is_save_diagnostic_source = vim.tbl_contains(source_methods, methods.internal.SAVE_DIAGNOSTICS)
    local handle_existing_buffer = function(buf)
        if buf.name == "" then
            return
        end

        M.try_add(buf.bufnr)
        if client and is_diagnostic_source then
            client.notify(methods.lsp.DID_CHANGE, { textDocument = { uri = vim.uri_from_bufnr(buf.bufnr) } })
        end
        if client and is_save_diagnostic_source then
            client.notify(methods.lsp.DID_SAVE, { textDocument = { uri = vim.uri_from_bufnr(buf.bufnr) } })
        end
    end

    vim.tbl_map(handle_existing_buffer, vim.fn.getbufinfo({ listed = 1 }))
end

function M.try_add(bufnr)
    local config = require("lspconfig")["null-ls"]
    if not (config and config.manager) then
        return
    end

    -- don't attach if no sources have been registered
    if not c.get()._registered then
        return
    end

    bufnr = bufnr or api.nvim_get_current_buf()
    local ft, buftype = api.nvim_buf_get_option(bufnr, "filetype"), api.nvim_buf_get_option(bufnr, "buftype")

    -- writing and immediately deleting a buffer (e.g. :wq from a git commit) triggers a bug on 0.5, but it's fixed on master
    if vim.fn.has("nvim-0.6") == 0 and ft == "gitcommit" then
        return
    end

    -- lspconfig checks if buftype == "nofile", but we want to be defensive, since (if configured) null-ls will try attaching to any buffer
    if buftype ~= "" then
        return
    end

    if not c.get()._all_filetypes and not u.filetype_matches(c.get()._filetypes, ft) then
        return
    end

    config.manager.try_add(bufnr)
end

return M
