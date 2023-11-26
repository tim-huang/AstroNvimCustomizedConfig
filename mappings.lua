-- Mapping data with "desc" stored directly by vim.keymap.set().
--
-- Please use this mappings table to set keyboard mapping since this is the
-- lower level configuration and more robust one. (which-key will
-- automatically pick-up stored data by this setting.)

local utils = require "astronvim.utils"
local is_available = utils.is_available

-- common mapping available in all mode
local commonMapping = {
  -- map Ctrl+, and Ctrl+. to prev/next buffer navigation
  ["<C-.>"] = {
    function() require("astronvim.utils.buffer").nav(vim.v.count > 0 and vim.v.count or 1) end,
    desc = "Next buffer",
  },
  ["<C-,>"] = {
    function() require("astronvim.utils.buffer").nav(-(vim.v.count > 0 and vim.v.count or 1)) end,
    desc = "Previous buffer",
  },
  ["<A-t>"] = {
    "<cmd>TodoTelescope<cr>",
    desc = "Todos",
  },
  ["<C-f>"] = {
    function() require("telescope.builtin").current_buffer_fuzzy_find() end,
    desc = "Find words in current buffer",
  },
}

-- map H & L to head & tail of line
local homeEndMapping = {
  H = { "^" },
  L = { "$" },
}

-- keymappings for debugger
local debugMapping = function()
  if is_available "nvim-dap" then
    local debug = {
      ["\\"] = { name = "Run/Debug..." },
      ["\\d"] = { function() require("dap").continue() end, desc = "Start/Continue (F5)" },
      -- FIXME: seems list_breakpoints() doesn't work properly
      ["\\l"] = { function() require("dap").list_breakpoints() end, desc = "List Breakpoints" },
      ["\\b"] = { function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint (F9)" },
      ["\\z"] = { function() require("dap").clear_breakpoints() end, desc = "Clear Breakpoints" },
      ["\\c"] = { function() require("dap").continue() end, desc = "Start/Continue (F5)" },
      ["\\B"] = {
        function()
          vim.ui.input({ prompt = "Condition: " }, function(condition)
            if condition then require("dap").set_breakpoint(condition) end
          end)
        end,
        desc = "Conditional Breakpoint (S-F9)",
      },
      ["<A-l>"] = { function() require("dap").step_into() end, desc = "Step Into (F11)" },
      ["<A-j>"] = { function() require("dap").step_over() end, desc = "Step Over (F10)" },
      ["<A-h>"] = { function() require("dap").step_out() end, desc = "Step Out (S-F11)" },
      ["\\t"] = {
        function() require("dap").terminate() end,
        desc = "Terminate Session (S-F5)",
      },
      ["\\p"] = { function() require("dap").pause() end, desc = "Pause (F6)" },
      ["\\r"] = { function() require("dap").restart_frame() end, desc = "Restart (C-F5)" },
      ["\\R"] = { function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
      ["\\C"] = { function() require("dap").run_to_cursor() end, desc = "Run To Cursor" },
      ["\\g"] = {
        function()
          vim.ui.input({ prompt = "Expression: " }, function(expr)
            if expr then require("dap").goto_(expr) end
          end)
        end,
        desc = "Run to line / cursor",
      },
    }
    -- persistent breakpoints
    if is_available "persistent-breakpoints.nvim" then
      local pb = require "persistent-breakpoints.api"
      debug["\\b"] = { function() pb.toggle_breakpoint() end, desc = "Toggle Breakpoint" }
      debug["\\z"] = { function() pb.clear_all_breakpoints() end, desc = "Clear Breakpoints" }
      debug["\\B"] = {
        function() pb.set_conditional_breakpoint() end,
        desc = "Conditional Breakpoint",
      }
    end

    -- evaluation && debugui
    if is_available "nvim-dap-ui" then
      debug["\\E"] = {
        function()
          vim.ui.input({ prompt = "Expression: " }, function(expr)
            if expr then require("dapui").eval(expr) end
          end)
        end,
        desc = "Evaluate Input",
      }
      debug["\\e"] = { function() require("dapui").eval() end, desc = "Evaluate current symbol" }
      debug["\\u"] = { function() require("dapui").toggle() end, desc = "Toggle Debugger UI" }
      debug["\\K"] = { function() require("dap.ui.widgets").hover() end, desc = "Debugger hover" }
      debug["\\s"] = {
        function()
          local widgets = require "dap.ui.widgets"
          widgets.centered_float(widgets.scopes)
        end,
        desc = "Scope",
      }
    end
    return debug
  end
  return {}
end

-- overwrite default maps
return function(maps)
  local n = {
    ["<leader>b"] = { name = "Buffers" },
    ["<leader>bl"] = { "<cmd>Telescope buffers<cr>", desc = "List buffers" },
    ["<leader>bD"] = {
      function()
        require("astronvim.utils.status").heirline.buffer_picker(
          function(bufnr) require("astronvim.utils.buffer").close(bufnr) end
        )
      end,
      desc = "Pick to close",
    },
    ["<leader>lo"] = { function() require("aerial").toggle() end, desc = "Outline" },
    ["+"] = { desc = "Increment", "<C-a>" },
    ["-"] = { "<C-x>", desc = "Decrement" },
    ["<tab>"] = {
      function() require("astronvim.utils.buffer").nav(vim.v.count > 0 and vim.v.count or 1) end,
      desc = "Next buffer",
    },

    -- toggle floating terminal window
    ["<C-t>"] = { "<cmd>ToggleTerm direction=float<cr>", desc = "ToggleTerm float" },

    -- resize window
    ["<C-S-Up>"] = { function() require("smart-splits").resize_up() end, desc = "Resize split up" },
    ["<C-S-Down>"] = { function() require("smart-splits").resize_down() end, desc = "Resize split down" },
    ["<C-S-Left>"] = { function() require("smart-splits").resize_left() end, desc = "Resize split left" },
    ["<C-S-Right>"] = { function() require("smart-splits").resize_right() end, desc = "Resize split right" },

    -- disable
    -- ["<leader>bl"] = false,
    ["<leader>br"] = false,
    ["<leader>lS"] = false,
    ["|"] = false,
    ["\\"] = false,
  }

  -- merge normal mode
  maps.n = vim.tbl_extend("force", maps.n, n, debugMapping(), homeEndMapping, commonMapping)
  -- merge insert mode
  maps.i = vim.tbl_extend("force", maps.i, commonMapping, {
    ["<C-l>"] = { function() vim.lsp.buf.signature_help() end, name = "Signature help" },
  })
  -- merge visual & selection mode
  maps.v = vim.tbl_extend("force", maps.v, homeEndMapping, commonMapping)
  -- merge operator-prepend mode
  maps.o = vim.tbl_extend("force", maps.o, homeEndMapping)

  -- map ALT+r to run snip (current line in normal & insert mode, but selected block in visual mode)
  maps.n["<A-r>"] = { "<cmd>SnipRun<cr>", desc = "Run current line" }
  maps.i["<A-r>"] = { "<cmd>SnipRun<cr>", desc = "Run current line" }
  maps.v["<A-r>"] = { ":'<,'>SnipRun<cr>", desc = "Run current line" }

  -- termial mode
  maps.t["<C-t>"] = { "<cmd>ToggleTerm direction=float<cr>", desc = "ToggleTerm float" }
  return maps
end
