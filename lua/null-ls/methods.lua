local lsp_methods = {
    INITIALIZE = "initialize",
    SHUTDOWN = "shutdown",
    EXIT = "exit",
    CODE_ACTION = "textDocument/codeAction",
    EXECUTE_COMMAND = "workspace/executeCommand",
    PUBLISH_DIAGNOSTICS = "textDocument/publishDiagnostics",
    FORMATTING = "textDocument/formatting",
    RANGE_FORMATTING = "textDocument/rangeFormatting",
    DID_CHANGE = "textDocument/didChange",
    DID_OPEN = "textDocument/didOpen",
    DID_CLOSE = "textDocument/didClose",
    DID_SAVE = "textDocument/didSave",
    HOVER = "textDocument/hover",
}
vim.tbl_add_reverse_lookup(lsp_methods)

local internal_methods = {
    CODE_ACTION = "NULL_LS_CODE_ACTION",
    DIAGNOSTICS = "NULL_LS_DIAGNOSTICS",
    SAVE_DIAGNOSTICS = "NULL_LS_SAVE_DIAGNOSTICS",
    FORMATTING = "NULL_LS_FORMATTING",
    RANGE_FORMATTING = "NULL_LS_RANGE_FORMATTING",
    HOVER = "NULL_LS_HOVER",
}
vim.tbl_add_reverse_lookup(internal_methods)

local lsp_to_internal_map = {
    [lsp_methods.CODE_ACTION] = {internal_methods.CODE_ACTION},
    [lsp_methods.FORMATTING] = {internal_methods.FORMATTING},
    [lsp_methods.RANGE_FORMATTING] = {internal_methods.RANGE_FORMATTING},
    [lsp_methods.DID_OPEN] = {internal_methods.DIAGNOSTICS, internal_methods.SAVE_DIAGNOSTICS},
    [lsp_methods.DID_CHANGE] = {internal_methods.DIAGNOSTICS},
    [lsp_methods.DID_SAVE] = {internal_methods.SAVE_DIAGNOSTICS},
    [lsp_methods.HOVER] = {internal_methods.HOVER},
}

local readable_map = {
    [internal_methods.CODE_ACTION] = "Code actions",
    [internal_methods.DIAGNOSTICS] = "Diagnostics",
    [internal_methods.SAVE_DIAGNOSTICS] = "Diagnostics on save",
    [internal_methods.FORMATTING] = "Formatting",
    [internal_methods.RANGE_FORMATTING] = "Range formatting",
    [internal_methods.HOVER] = "Hover",
}

local M = {}
M.lsp = lsp_methods
M.internal = internal_methods
M.map = lsp_to_internal_map
M.readable = readable_map

return M
