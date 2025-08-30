-- ~/.config/nvim/lua/user/dap-python.lua
local dap = require("dap")
local dapui = require("dapui")

-- ====================
-- Python DAP Adapter (debugpy)
-- ====================
dap.adapters.python = {
  type = "executable",
  command = vim.fn.exepath("python") or "python",
  args = { "-m", "debugpy.adapter" },
  name = "debugpy",
}

-- ====================
-- Python Configurations
-- ====================
dap.configurations.python = {
  {
    type = "python",
    request = "launch",
    name = "Debug current file",
    program = "${file}", -- current file
    pythonPath = function()
      local venv = os.getenv("VIRTUAL_ENV")
      if venv then
        return venv .. "/bin/python"
      else
        return vim.fn.exepath("python") or "python"
      end
    end,
  },
  {
    type = "python",
    request = "launch",
    name = "Debug pytest (nearest test)",
    module = "pytest", -- run pytest as a module
    args = function()
      local file = vim.fn.expand("%")
      local current_test = vim.fn.expand("<cword>") -- function under cursor
      return { file, "-k", current_test }
    end,
    pythonPath = function()
      local venv = os.getenv("VIRTUAL_ENV")
      if venv then
        return venv .. "/bin/python"
      else
        return vim.fn.exepath("python") or "python"
      end
    end,
  },
}

-- ====================
-- Keymaps
-- ====================
vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>pdn", function()
  local ft = vim.bo.filetype
  local configs = dap.configurations[ft]
  if configs and #configs > 0 then
    dap.run(configs[1]) -- debug current file
  else
    print("No DAP configuration for filetype: " .. ft)
  end
end, { noremap = true, silent = true })

-- Debug nearest test
vim.keymap.set("n", "<leader>pdt", function()
  local ft = vim.bo.filetype
  local configs = dap.configurations[ft]
  if configs and #configs > 1 then
    dap.run(configs[2]) -- debug pytest nearest test
  else
    print("No DAP configuration for nearest test for filetype: " .. ft)
  end
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>du", dapui.toggle, { noremap = true, silent = true })

-- ====================
-- Optional: run pytest from cursor or file
-- ====================
vim.keymap.set("n", "<leader>ptn", function()
  local word = vim.fn.expand("<cword>")
  vim.cmd("split | terminal pytest -k " .. word)
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>ptt", function()
  vim.cmd("split | terminal pytest")
end, { noremap = true, silent = true })

