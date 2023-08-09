local utils = require "astronvim.utils"
local is_available = utils.is_available

-- terminate dapDebugServer automatically after debugger detached
if is_available "nvim-dap" then
  require("dap").listeners.after.event_terminated["dapui_config"] = function(session)
    if session.parent then return end

    if is_available "nvim-dap-ui" then require("dapui").close {} end

    vim.fn.system(
      "ps -fea | grep node | grep 'dapDebugServer.js "
        .. session.adapter["port"]
        .. "' | grep -v grep | awk '{print $2}' | xargs kill -9"
    )
  end

  local setupRustDebugger = function()
    local rustDefaultConfig = {
      executable = "",
    }

    -- register your settings schema with Neodev, so auto-completion will work in the json files
    require("neoconf.plugins").register {
      name = "rust",
      on_schema = function(schema)
        -- this call will create a json schema based on the lua types of your default settings
        schema:import("rust", rustDefaultConfig)
        -- Optionally update some of the json schema
        schema:set("rust.executable", {
          description = "Specify executable file for debugger, normally it should be target/debug/your-project-name",
          -- anyOf = {
          --   { type = "string" },
          -- },
        })
      end,
    }

    require("dap").configurations.rust = {
      {
        name = "Debug project",
        type = "codelldb",
        request = "launch",
        program = function()
          local rustConfig = require("neoconf").get("neoconf.plugins.rust", rustDefaultConfig)
          vim.notify("Rust config loaded :" .. rustConfig.executable)
          if rustConfig.executable then return vim.fn.getcwd() .. "/" .. rustConfig.executable end
          return vim.fn.input("Path to executable(it's configurable in neoconf): ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
      },
    }
  end

  setupRustDebugger()
end

return {}
