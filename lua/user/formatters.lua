-- ~/.config/nvim/lua/user/formatters.lua
local M = {}

function M.setup()
  -- null-ls setup for Python
  local null_ls = require("null-ls")
  null_ls.setup({
    sources = {
      null_ls.builtins.formatting.black,
    },
  })

  -- Zig: LSP formatting via ZLS
  vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.zig",
    callback = function(args)
      vim.lsp.buf.format({
        bufnr = args.buf,
        filter = function(client)
          return client.name == "zls"
        end,
      })
    end,
  })

  -- Python: format on save via LSP (null-ls)
  vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.py",
    callback = function(args)
      vim.lsp.buf.format({ bufnr = args.buf })
    end,
  })
end

return M

