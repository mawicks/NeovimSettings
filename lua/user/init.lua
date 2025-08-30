require("user.dap-zig")
require("user.dap-python")
require("user.dap-keymaps")

return {
  polish = function()
    -- Load formatters on startup
    require("user.formatters").setup()
  end,
}

