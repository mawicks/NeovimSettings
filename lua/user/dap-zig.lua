-- ~/.config/nvim/lua/user/dap-zig.lua
local dap = require("dap")
local dapui = require("dapui")

-- ====================
-- DAP Adapter (codelldb via Mason)
-- ====================
dap.adapters.zig = {
  type = "server",
  port = "${port}",
  executable = {
    command = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb",
    args = { "--port", "${port}" },
  },
  name = "codelldb",
}

-- ====================
-- DAP Configurations for Zig
-- ====================
dap.configurations.zig = {
  {
    name = "Debug Zig test binary (all tests)",
    type = "zig",
    request = "launch",
    program = function()
      local file = vim.fn.expand("%")
      vim.fn.system("zig test -femit-bin=__zig_test_bin__ " .. file)
      return vim.fn.getcwd() .. "/__zig_test_bin__"
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
    args = {},
  },
  {
    name = "Debug Zig test binary (nearest test)",
    type = "zig",
    request = "launch",
    program = function()
      local file = vim.fn.expand("%")
      local line = vim.fn.getline(".")
      local test_name = line:match('test%s+"([^"]+)"')
      if not test_name then
        print("No test found on current line, building all tests instead.")
        vim.fn.system("zig test -femit-bin=__zig_test_bin__ " .. file)
      else
        vim.fn.system("zig test -femit-bin=__zig_test_bin__ " .. file
          .. ' --test-filter "' .. test_name .. '"')
      end
      return vim.fn.getcwd() .. "/__zig_test_bin__"
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
    args = {},
  },
}

-- ====================
-- Auto open DAP UI
-- ====================
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

-- ====================
-- Unified DAP Keymaps
-- ====================
vim.keymap.set("n", "<leader>zdb", dap.toggle_breakpoint, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>zdn", function()
  local configs = dap.configurations.zig
  dap.run(configs[1])  -- debug all tests
end, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>zdt", function()
  local configs = dap.configurations.zig
  dap.run(configs[2])  -- debug nearest test
end, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>du", dapui.toggle, { noremap = true, silent = true })

-- ====================
-- Terminal Test Runner (no debug binary)
-- ====================
local function run_nearest_zig_test()
  local line = vim.fn.getline(".")
  local test_name = line:match('test%s+"([^"]+)"')
  local file = vim.fn.expand("%")

  if test_name then
    vim.cmd("split | terminal zig test " .. file
      .. ' --test-filter "' .. test_name .. '"')
  else
    vim.cmd("split | terminal zig test " .. file)
  end
end

local function run_all_zig_tests()
  local file = vim.fn.expand("%")
  vim.cmd("split | terminal zig test " .. file)
end

vim.keymap.set("n", "<leader>ztn", run_nearest_zig_test, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>ztt", run_all_zig_tests, { noremap = true, silent = true })

