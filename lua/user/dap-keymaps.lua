local dap = require("dap")
local dapui = require("dapui")

-- Toggle breakpoint
vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { noremap = true, silent = true })

-- Start debugging current file (language-agnostic)
vim.keymap.set("n", "<leader>dn", function()
  local ft = vim.bo.filetype
  local configs = dap.configurations[ft]
  if configs and #configs > 0 then
    dap.run(configs[1])
  else
    print("No DAP configuration for filetype: " .. ft)
  end
end, { noremap = true, silent = true })

-- Toggle debugging UI
vim.keymap.set("n", "<leader>du", dapui.toggle, { noremap = true, silent = true })

